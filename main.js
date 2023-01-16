//
// Flow playground
//
// Copyright © 2022 by luk3yx.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

"use strict";

// Overridden by init.lua once it loads
var run_playground_code;
if (!window.run_playground_code) {
    var playground_code_tmp;
    function run_playground_code(code) {
        playground_code_tmp = code;
    }
}

const shareLinkElem = document.getElementById("share-link");
shareLinkElem.addEventListener("blur", () => {
    shareLinkElem.classList.remove("active");
});

function shareCode() {
    shareLinkElem.classList.add("active");
    window.location.hash = '#code=' + encodeURIComponent(editor.getValue());
    shareLinkElem.value = window.location.href;
    shareLinkElem.select();
}

var editor;
var untrustedCode = false;
function runCode() {
    // Warn the user if they're about to run untrusted code
    if (untrustedCode && !confirm("Untrusted code could freeze this webpage " +
            "and may potentially be able to break out of the Lua sandbox " +
            "and execute arbitrary JavaScript.\n" +
            "Are you sure you want to continue?")) {
        return;
    }

    // Remove the untrustedCode flag and run the code
    untrustedCode = false;
    run_playground_code(editor.getValue());
}

const dropdown = document.getElementById("code-preset");
var sharedCode;
if (window.location.hash.startsWith("#code=")) {
    const option = document.createElement("option");
    option.value = "shared";
    option.textContent = "Shared link";
    dropdown.appendChild(option);
    dropdown.value = "shared";
    sharedCode = decodeURIComponent(window.location.hash.slice(6));
}

// Handle switching between tutorials
async function updateCode() {
    editor.setScrollPosition({scrollTop: 0});
    if (dropdown.value === "shared") {
        // Load in code from the URL and add a warning
        untrustedCode = true;
        editor.setValue(sharedCode);
        run_playground_code("");
        return;
    }

    // Fecth tutorial code
    untrustedCode = false;
    editor.setValue("Loading...");
    const resp = await fetch(`tutorials/${dropdown.value}`);
    if (resp.ok) {
        const code = await resp.text();
        editor.setValue(code);
        run_playground_code(code);
    } else {
        editor.setValue(`${resp.status} error when fetching code`);
    }
}

dropdown.addEventListener("change", updateCode);

// Create the editor
const container = document.getElementById("code-container");
require.config({
    paths: {vs: "https://unpkg.com/monaco-editor@0.34.1/min/vs"}
});
require(["vs/editor/editor.main"], () => {
    container.innerHTML = "";
    editor = monaco.editor.create(container, {
        // value: code,
        language: 'lua',
        theme: 'vs-dark',
        automaticLayout: true,
        scrollBeyondLastLine: false,
        wordWrap: true
    });

    editor.addAction({
        id: 'playground-run',
        label: 'Run code',
        contextMenuGroupId: 'playground',
        contextMenuOrder: 1.5,
        run: runCode,
    });

    editor.addAction({
        id: 'playground-share',
        label: 'Share code',
        contextMenuGroupId: 'playground',
        contextMenuOrder: 1.5,
        run: shareCode,
    });

    updateCode();
    document.body.removeChild(document.getElementById("loader"));
});

// Handle run button clicks
document.getElementById("run").addEventListener("click", runCode);

// Add a confirmation message before closing the tab
window.addEventListener("beforeunload", e => {
    return (e || window.event).returnValue = "You will lose your code!";
});
