$.SyntaxHighlighter.init 
  'lineNumbers': false 
  'theme': 'sunburst' 
  'wrapLines': true 

expanded = false
$('#header').live 'click', ->
  if (!expanded)
    $('#header,#radial').animate {
      height: '+=215'
    }, 'slow', 'easeOutBounce'
    expanded = true
  else
    window.location = '/'
