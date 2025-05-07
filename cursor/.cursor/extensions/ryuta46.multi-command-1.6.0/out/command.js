"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Command = void 0;
const vscode = require("vscode");
const vscodeVariables = require('vscode-variables');
class Command {
    constructor(exe, args, repeat, onSuccess, onFail, variableSubstitution) {
        this.exe = exe;
        this.args = args;
        this.repeat = repeat;
        this.onSuccess = onSuccess;
        this.onFail = onFail;
        this.variableSubstitution = variableSubstitution;
    }
    execute() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                if (this.args) {
                    let args;
                    if (this.variableSubstitution) {
                        args = this.substituteVariables(this.args);
                    }
                    else {
                        args = this.args;
                    }
                    for (let i = 0; i < this.repeat; i++) {
                        yield vscode.commands.executeCommand(this.exe, args);
                    }
                }
                else {
                    for (let i = 0; i < this.repeat; i++) {
                        yield vscode.commands.executeCommand(this.exe);
                    }
                }
                if (this.onSuccess) {
                    for (let command of this.onSuccess) {
                        yield command.execute();
                    }
                }
            }
            catch (e) {
                if (this.onFail) {
                    for (let command of this.onFail) {
                        yield command.execute();
                    }
                }
                else {
                    throw (e);
                }
            }
        });
    }
    substituteVariables(args) {
        if (typeof args === 'string') {
            args = args.replace(/\${userHome}/g, process.env['HOME'] || '');
            return vscodeVariables(args);
        }
        else if (typeof args === 'object') {
            let rt = {};
            for (const key of Object.keys(args)) {
                rt[key] = this.substituteVariables(args[key]);
            }
            return rt;
        }
        else {
            return args;
        }
    }
}
exports.Command = Command;
//# sourceMappingURL=command.js.map