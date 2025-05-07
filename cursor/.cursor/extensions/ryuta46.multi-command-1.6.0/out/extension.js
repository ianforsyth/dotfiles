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
exports.pickMultiCommand = exports.deactivate = exports.activate = void 0;
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require("vscode");
const command_1 = require("./command");
const multiCommand_1 = require("./multiCommand");
function implementsCommandMap(arg) {
    return arg !== null && typeof arg === "object";
}
function createMultiCommand(id, settings) {
    const label = settings.label;
    const description = settings.description;
    const interval = settings.interval;
    const languages = settings.languages;
    function createCommand(command) {
        var _a, _b, _c, _d;
        let exe;
        let args;
        let repeat = 1;
        let variableSubstitution;
        let onSuccess;
        let onFail;
        if (typeof command === "string") {
            let conditionedCommands = command.split(" || ");
            if (conditionedCommands.length > 1) {
                conditionedCommands = conditionedCommands.map((s) => s.trim());
                exe = conditionedCommands.shift();
                onFail = [createCommand(conditionedCommands.join(" || "))];
            }
            else {
                exe = command;
            }
            variableSubstitution = false;
        }
        else {
            exe = command.command;
            args = command.args;
            repeat = (_a = command.repeat) !== null && _a !== void 0 ? _a : 1;
            variableSubstitution = (_b = command.variableSubstitution) !== null && _b !== void 0 ? _b : false;
            onSuccess = (_c = command.onSuccess) === null || _c === void 0 ? void 0 : _c.map((c) => createCommand(c));
            onFail = (_d = command.onFail) === null || _d === void 0 ? void 0 : _d.map((c) => createCommand(c));
        }
        return new command_1.Command(exe, args, repeat, onSuccess, onFail, variableSubstitution);
    }
    const sequence = settings.sequence.map((command) => {
        return createCommand(command);
    });
    return new multiCommand_1.MultiCommand(id, label, description, interval, sequence, languages);
}
let multiCommands;
function refreshUserCommands(context) {
    let configuration = vscode.workspace.getConfiguration("multiCommand");
    let commands = new Map();
    let commandList = configuration.get("commands") || [];
    // Dispose current settings.
    for (let element of context.subscriptions) {
        element.dispose();
    }
    if (Array.isArray(commandList)) {
        for (let commandSettingsWithKey of commandList) {
            commands.set(commandSettingsWithKey.command, commandSettingsWithKey);
        }
    }
    else if (implementsCommandMap(commandList)) {
        let commandObject = commandList;
        Object.keys(commandObject).forEach((key) => {
            commands.set(key, commandObject[key]);
        });
    }
    multiCommands = [];
    commands.forEach((value, key) => {
        const multiCommand = createMultiCommand(key, value);
        multiCommands.push(multiCommand);
        context.subscriptions.push(vscode.commands.registerCommand(key, () => __awaiter(this, void 0, void 0, function* () {
            yield multiCommand.execute();
        })));
    });
}
// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
function activate(context) {
    refreshUserCommands(context);
    vscode.workspace.onDidChangeConfiguration(() => {
        refreshUserCommands(context);
    });
    vscode.commands.registerCommand("extension.multiCommand.execute", (args = {}) => __awaiter(this, void 0, void 0, function* () {
        try {
            if (args.command) {
                yield vscode.commands.executeCommand(args.command);
            }
            else if (args.sequence) {
                const multiCommand = createMultiCommand("", args);
                yield multiCommand.execute();
            }
            else {
                yield pickMultiCommand();
            }
        }
        catch (e) {
            vscode.window.showErrorMessage(`${e.message}`);
        }
    }));
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
function pickMultiCommand() {
    var _a;
    return __awaiter(this, void 0, void 0, function* () {
        let languageId = (_a = vscode.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document.languageId;
        const picks = multiCommands.filter((multiCommand) => {
            var _a, _b;
            if (languageId) {
                return ((_b = (_a = multiCommand.languages) === null || _a === void 0 ? void 0 : _a.indexOf(languageId)) !== null && _b !== void 0 ? _b : 1) >= 0;
            }
            else {
                return true;
            }
        }).map((multiCommand) => {
            return {
                label: multiCommand.label || multiCommand.id,
                description: multiCommand.description || "",
                multiCommand: multiCommand,
            };
        });
        const item = yield vscode.window.showQuickPick(picks, {
            placeHolder: `Select one of the multi commands...`,
        });
        if (!item) {
            return;
        }
        yield item.multiCommand.execute();
    });
}
exports.pickMultiCommand = pickMultiCommand;
//# sourceMappingURL=extension.js.map