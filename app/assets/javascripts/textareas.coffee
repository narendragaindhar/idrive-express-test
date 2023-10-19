document.addEventListener 'turbolinks:load', ->
  $('textarea[data-autogrow]').autoGrow()

  document.querySelectorAll('textarea[data-codemirror=true]').forEach (element)->
    editor = CodeMirror.fromTextArea(element, {
      lineNumbers: true,
      mode: element.dataset.mode,
      readOnly: element.dataset.readonly
    })

    if element.dataset.sqlTables
      editor.setOption('extraKeys', {'Ctrl-Space': 'autocomplete'})
      editor.setOption('hint', CodeMirror.hint.sql)
      editor.setOption('hintOptions', {
        tables: JSON.parse(element.dataset.sqlTables)
      })

    element.setAttribute('data-codemirror', 'false') # make sure it won't init again
    element.CodeMirror = editor

  return
