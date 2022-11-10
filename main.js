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
if (!window.run_playground_code) {
    var playground_code_tmp;
    function run_playground_code(code) {
        playground_code_tmp = code;
    }
}

// Handle switching between tutorials
var editor;
const dropdown = document.getElementById("code-preset");
async function updateCode() {
    editor.setValue("Loading...");
    const resp = await fetch(`tutorials/${dropdown.value}`);
    if (resp.ok) {
        const code = await resp.text();
        editor.setValue(code);
        run_playground_code(code);
    } else {
        editor.setValue(`${resp.status} error when fetching code`);
    }
    editor.setScrollPosition({scrollTop: 0});
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
    updateCode();
    document.body.removeChild(document.getElementById("loader"));
});

// Handle run button clicks
document.getElementById("run").addEventListener("click", () => {
    run_playground_code(editor.getValue());
});

// Add a confirmation message before closing the tab
window.addEventListener("beforeunload", e => {
    return (e || window.event).returnValue = "You will lose your code!";
});
