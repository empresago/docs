#!/usr/bin/env node
/**
 * Escolhe o script de fetch-env conforme o SO (linux | darwin | win32).
 */
const { spawnSync } = require("node:child_process");
const path = require("node:path");

const dir = __dirname;
const root = path.join(dir, "..", "..");
const { platform } = process;

const runners = {
  linux: { cmd: "bash", args: [path.join(dir, "linux.sh")] },
  darwin: { cmd: "bash", args: [path.join(dir, "darwin.sh")] },
  win32: {
    cmd: "powershell.exe",
    args: ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path.join(dir, "win.ps1")],
  },
};

const runner = runners[platform];
if (!runner) {
  console.error(`❌ SO não suportado para fetch-env: ${platform}`);
  process.exit(1);
}

const label = platform === "win32" ? "Windows" : platform === "darwin" ? "macOS" : "Linux";
console.log(`===> fetch-env (${label})`);

const result = spawnSync(runner.cmd, runner.args, { cwd: root, stdio: "inherit" });
process.exit(result.status ?? 1);
