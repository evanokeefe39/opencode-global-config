export type LogLevel = "debug" | "info" | "warn" | "error";

const level: LogLevel = (process.env.LOG_LEVEL as LogLevel) || "info";

function fmt(l: string, ns: string, msg: string) {
  return `${new Date().toISOString()} ${l.toUpperCase()} ${ns} ${msg}`;
}

export function logger(ns = "app") {
  return {
    debug: (m: string) => level === "debug" && console.log(fmt("debug", ns, m)),
    info:  (m: string) => ["debug","info"].includes(level) && console.log(fmt("info", ns, m)),
    warn:  (m: string) => console.warn(fmt("warn", ns, m)),
    error: (m: string) => console.error(fmt("error", ns, m)),
  };
}
