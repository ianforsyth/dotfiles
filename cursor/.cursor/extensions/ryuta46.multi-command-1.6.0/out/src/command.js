"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Command = void 0;
const vscode = require("vscode");
//import * as vscodeVariables from "vscode-variables";
const vscodeVariables = require('vscode-variables');
class Command {
    constructor(exe, args) {
        this.exe = exe;
        this.args = args;
    }
    execute() {
        if (this.args === null) {
            return vscode.commands.executeCommand(this.exe);
        }
        else {
            return vscode.commands.executeCommand(this.exe, this.resolve(this.args));
        }
    }
    resolve(args) {
        if (typeof args === 'string') {
            return vscodeVariables(args);
        }
        else if (typeof args === 'object') {
            for (const key of Object.keys(args)) {
                args[key] = this.resolve(args[key]);
            }
            return args;
        }
        else {
            return args;
        }
    }
}
exports.Command = Command;
//# sourceMappingURL=command.js.map