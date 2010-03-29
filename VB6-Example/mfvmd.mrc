;My First VB6 mIRC Dll
on *:load: {
  comreg $+(",$scriptdir,example.dll,")
  ; project name:
  set %vbdll.p example
}
alias vbdll { 
  .comopen vbcom example.Class1 | var %result = $com(vbcom,funcUcase,1,bstr,$1) | echo -a Result: $com(vbcom).result | .comclose vbcom
  if ($comerr) { comreg $+(",$scriptdir,example.dll,") | .comopen vbcom example.Class1 | if ($comerr) halt }
}
alias vbdll2 { 
  .comopen vbcom example.Class1 | var %result = $com(vbcom,funcLcase,1,bstr,$1) | echo -a Result: $com(vbcom).result | .comclose vbcom
  if ($comerr) { comreg $+(",$scriptdir,example.dll,") | .comopen vbcom example.Class1 | if ($comerr) halt }
}
alias vbdll3 { 
  .comopen vbcom example.Class1 | var %result = $com(vbcom,funcCopy,1,bstr,$1) | echo -a Result: $com(vbcom).result | .comclose vbcom
  if ($comerr) { comreg $+(",$scriptdir,example.dll,") | .comopen vbcom example.Class1 | if ($comerr) halt }
}
