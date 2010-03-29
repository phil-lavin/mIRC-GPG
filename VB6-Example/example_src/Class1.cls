VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Class1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Function funcUcase(text As String)
  funcUcase = text & " in upper is " & UCase(text)
End Function

Public Function funcLcase(text As String)
  funcLcase = text & " in lower is " & LCase(text)
End Function

Public Function funcCopy(text As String)
  funcCopy = "Copyright PHILZ0R!"
End Function

