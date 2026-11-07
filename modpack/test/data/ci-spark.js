ServerEvents.loaded(e => {
  e.server.runCommandSilent('spark healthreport')
  e.server.runCommandSilent('spark profiler start')
})
ServerEvents.unloaded(e => {
  e.server.runCommandSilent('spark profiler stop --save-to-file')
})
