; mirc-gpg by Phil Lavin (0x3FFC291A) & Allan Jude (0x7F697DBA)
; SVN: $Id: gpg.mrc 4 2010-03-28 17:58:17Z allan.jude $
on *:load:{
  set %gpg.scriptver 0.1
  set %gpg.path $$?="Enter the path to GPG"
}

alias runAppHidden {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, Run, 1, *bstr, $$1-, int, 0, bool, true)
}

alias runApp {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, Run, 1, *bstr, $$1-, int, 3, bool, true)
}

alias runAppHiddenNoWait {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, Run, 1, *bstr, $$1-, int, 0)
}

alias runAppMinNoWait {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, Run, 1, *bstr, $$1-, int, 7)
}

alias runAppNoWait {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, Run, 1, *bstr, $$1-, int, 3)
}

alias appactivate {
  .comopen a WScript.Shell
  .comclose a $com(a,AppActivate,3,*bstr,$$1-)
}

alias sendKeys {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, SendKeys, 1, *bstr, $$1-)
}

alias f8 {
  gpgEncrypt
}

alias gpgEncrypt {
  $dialog(spk, selPubKey)

  set %gpg.sourcefile $scriptdir $+ gpg\source.txt
  set %gpg.destfile $scriptdir $+ gpg\dest.gpg
  set %gpg.outfile $scriptdir $+ gpg\out.txt

  write -c " $+ %gpg.sourcefile $+ " $editbox($active, 0)

  runapp cmd /c %gpg.path $+ gpg.exe -e -a %gpg.recipients -o " $+ %gpg.destfile $+ " " $+ %gpg.sourcefile $+ " > " $+ %gpg.outfile $+ " 2>&1

  if ($lines(%gpg.outfile) > 0) {
    echo -a Possible error detected. GPG produced output:

    set %gpg.i 1

    while (%gpg.i <= $lines(%gpg.outfile)) {
      echo -a $read(%gpg.outfile, %gpg.i)
      inc %gpg.i
    }
  }

  editbox -a $null

  set %gpg.i 1

  while (%gpg.i <= $lines(%gpg.destfile)) {
    set %gpg.line $read(%gpg.destfile, %gpg.i)

    if ($len(%gpg.line) == 0) {
      set %gpg.line ~
      msg $active Comment: GeekShed GPG for IRC by: Phil & Allan %gpg.scriptver http://mirc-gpg.googlecode.com
    }

    msg $active %gpg.line
    inc %gpg.i
  }

  runapphidden cmd /c del " $+ $scriptdir $+ gpg\*" /Q
}

alias gpgDecrypt {
  set %gpg.destfile $4- $+ .unenc
  runappminnowait cmd /c %gpg.path $+ gpg.exe -d -o " $+ %gpg.destfile $+ " " $+ $4- $+ " 2> " $+ $4- $+ .out $+ "
  .timer 1 1 gpgDecrypt2 $1-
}

alias gpgDecrypt2 {
  if ($lines($4- $+ .out) == 0) {
    .timergpg $+ . $+ $3 $+ . $+ $2 off
    set %gpg.pass $?="Enter Private Key Password"

    appactivate cmd.exe
    .timer 1 1 sendkeys %gpg.pass $+ $chr(13) $+ %gpg.pass $+ $chr(13) $+ %gpg.pass $+ $chr(13)
    .timer 1 2 gpgDecrypt3 $1-
  }
  else {
    echo -a Possible error detected. GPG produced output:

    set %gpg.i 1

    while (%gpg.i <= $lines($4- $+ .out)) {
      echo -a $read($4- $+ .out, %gpg.i)
      inc %gpg.i
    }

    runapphidden cmd /c del " $+ $4- $+ *" /Q
    .timergpg $+ . $+ $3 $+ . $+ $2 off
  }
}

alias gpgDecrypt3 {
  set %gpg.temp $read($4- $+ .out, w, *bad passphrase*);

  if ($readn != 0) {
    echo -a 4Bad Passphrase!
  }
  else {
    echo -a ----DECRYPTED MESSAGE FROM $1 IN $2 ON $3 $+ ----

    set %gpg.i 1

    while (%gpg.i <= $lines($4- $+ .unenc)) {
      set %gpg.readline $read($4- $+ .unenc, %gpg.i)
      if ($len(%gpg.readline) > 0) {
        echo -a %gpg.readline
      }
      else {
        echo -a $chr(1)
      }
      inc %gpg.i
    }
    echo -a ----END MESSAGE-----
  }

  runapphidden cmd /c del " $+ $4- $+ *" /Q
}

alias addKeysToSPK {
  set %gpg.keyfile $scriptdir $+ gpg\keylist.txt

  runapphidden cmd /c %gpg.path $+ gpg.exe --list-keys > " $+ %gpg.keyfile $+ "

  ; Reset $readn - is there a better way?
  set %gpg.random $read(%gpg.keyfile, 1)
  unset %gpg.random

  set %gpg.readn 0

  while ($readn != 0) {
    set %gpg.line $read(%gpg.keyfile, s, uid, $calc(%gpg.readn + 1))

    if ($readn != 0) {
      did -a spk 1 %gpg.line
      set %gpg.readn $readn
    }
  }
}

on *:dialog:spk:init:*:{
  addKeysToSPK
}

on *:dialog:spk:close:*:{
  set %gpg.i 1
  set %gpg.recipients $null

  while (%gpg.i <= $did(1).lines) {
    if ($did(1, %gpg.i).cstate == 1) {
      set %gpg.revitem $rev($did(1, %gpg.i))
      set %gpg.emailstart $pos(%gpg.revitem, >, 1)
      set %gpg.emailend $pos(%gpg.revitem, <, 1)

      set %gpg.recipients %gpg.recipients -r $rev($mid(%gpg.revitem, $calc(%gpg.emailstart + 1), $calc(%gpg.emailend - %gpg.emailstart - 1)))
    }

    inc %gpg.i
  }
}

dialog selPubKey {

  title "Select Public Key"

  size -1 -1 250 150

  option dbu

  list 1, 10 10 230 100, multisel check result

  button "OK", 2, 65 120 50 20, ok
  button "Cancel", 3, 125 120 50 20, cancel
}

alias dodel {
  if (%gpg.textin. [ $+ [ $1 $+ .  [ $+ [ $2 ] ] ] ] == $null) {
    runapphidden cmd /c del " $+ $scriptdir $+ gpg\textin\ $+ $1 $+ - $+ $2 $+ .*" /Q
    .timergpg $+ . $+ $1 $+ . $+ $2 off
  }
}

on 1:TEXT:-----BEGIN PGP MESSAGE-----:#:{
  set -u10 %gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] 1
  write -c " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $1-
  .timergpg $+ . $+ $network $+ . $+ $nick 0 1 dodel $network $nick
}

on 1:TEXT:-----END PGP MESSAGE-----:#:{
  if (%gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] != $null) {
    .timergpg $+ . $+ $network $+ . $+ $nick off
    unset %gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ]
    write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $1-
  }

  gpgdecrypt $nick $chan $network $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg
}

on 1:TEXT:*:#:{
  if ($1 != -----END PGP MESSAGE-----) {
    if (%gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] != $null) {
      set -u10 %gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] 1
      if ($1- != ~) {
        write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $1-
      }
      else {
        write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $chr(13)
      }
    }
  }
}

alias rev {
  if ($1) {
    var %gpg.c $strip($1-),%gpg.a $len(%gpg.c)
    while (%gpg.a >= 1) {
      var %gpg.b %gpg.b $+ $replace($mid(%gpg.c,%gpg.a,1),$chr(32),$str($chr(32),2))
      dec %gpg.a
    }
  }
  return %gpg.b
}
