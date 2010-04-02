; mirc-gpg by Phil Lavin (0x3FFC291A) & Allan Jude (0x7F697DBA)
; SVN: $Id$

alias gpg.setver {
  set %gpg.scriptver 0.7
}

alias gpg.updatever {
  if ($file($script).mtime != %gpg.scriptmtime) {
    set %gpg.scriptmtime $file($script).mtime
    gpg.setver
  }
}

menu status,channel,query,nicklist,menubar {
  -
  mIRC-GPG
  .Automatic Decryption
  ..$iif($group(#gpg).status == on,$style(1)) Enable:.enable #gpg
  ..$iif($group(#gpg).status == off,$style(1)) Disable:.disable #gpg
  .Generate a new Key:runapp cmd /c gpg --gen-key
  ;.Upload my Keys:runapp cmd /c gpg --keyserver gpg.geekshed.net --send-keys ; doesn't work yet
  .Refresh my Keys:echo -at Refreshing keys from gpg.geekshed.net please wait... | runapphidden cmd /c gpg --keyserver gpg.geekshed.net --refresh-keys | echo -at All keys have been refreshed
  .Search for Keys:runapp cmd /c gpg --keyserver gpg.geekshed.net --search-keys $$?="Search Parameters (Email is best)"
  ;.Set Key Trust: ;not implemented
}

on *:load:{
  gpg.setver

  if (!$isdir($scriptdir $+ gpg)) {
    runapphidden cmd /c mkdir " $+ $scriptdir $+ gpg $+ "
  }
  if (!$isdir($scriptdir $+ gpg\textin)) {
    runapphidden cmd /c mkdir " $+ $scriptdir $+ gpg\textin $+ "
  }

  if ($isfile(C:\Program Files\GNU\GnuPG\gpg.exe)) {
    set %gpg.path C:\Program Files\GNU\GnuPG\
    echo -at GPG Found At C:\Program Files\GNU\GnuPG\
  }
  elseif ($isfile(C:\Program Files (x86)\GNU\GnuPG\gpg.exe)) {
    set %gpg.path C:\Program Files (x86)\GNU\GnuPG\
    echo -at GPG Found At C:\Program Files (x86)\GNU\GnuPG\
  }
  else {
    set %gpg.path $$?="I can't find GPG! Enter the path to the directory in which gpg.exe resides:"
  }

  if (; $+ %gpg.path !isin $env(path)) {
    env path $env(path) $+ ; $+ %gpg.path
  }
}

on *:START:{
  gpg.setver

  if (%gpg.path != $null) {
    if (; $+ %gpg.path !isin $env(path)) {
      env path $env(path) $+ ; $+ %gpg.path
    }
  }

  .timergpgverupdate 0 60 gpg.updatever
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

alias runAppMin {
  set %gpg.runname rah $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z) $+ $rand(a,z)

  .comopen %gpg.runname WScript.Shell
  .comclose %gpg.runname $com(%gpg.runname, Run, 1, *bstr, $$1-, int, 7, bool, true)
}

alias env {
  if ($isid) {
    var %x = $dll($scriptdir $+ menv.dll, getEnv, $1)
    if ($gettok(%x, 1, 32) == OK) {
      if ($prop == exists) {
        return 1
      }
      return $gettok(%x, 2-, 32)
    }
    else {
      if ($prop == exists) {
        return 0
      }
      return $null
    }
  }
  else {
    var %x = $dll($scriptdir $+ menv.dll, putEnv, $1 $+ = $+ $2-)
  }
}

alias f8 {
  gpgEncrypt
}

alias gpgEncrypt {
  if (!$editbox($active, 0)) {
    echo -a No Text To Send
  }
  else {
    $dialog(spk, selPubKey)

    if (%gpg.halt == $null) {
      set %gpg.sourcefile $scriptdir $+ gpg\source.txt
      set %gpg.destfile $scriptdir $+ gpg\dest.gpg
      set %gpg.outfile $scriptdir $+ gpg\out.txt

      write -c " $+ %gpg.sourcefile $+ " $editbox($active, 0)

      runapp cmd /c gpg -e -a %gpg.recipients -o " $+ %gpg.destfile $+ " " $+ %gpg.sourcefile $+ " > " $+ %gpg.outfile $+ " 2>&1

      if ($lines(%gpg.outfile) > 0) {
        echo -at Possible error detected. GPG produced output:

        set %gpg.i 1

        while (%gpg.i <= $lines(%gpg.outfile)) {
          echo -at $read(%gpg.outfile, %gpg.i)
          inc %gpg.i
        }
      }

      set %gpg.editbox $editbox($active, 0)
      editbox -a $null

      set %gpg.i 1

      while (%gpg.i <= $lines(%gpg.destfile)) {
        set %gpg.line $read(%gpg.destfile, %gpg.i)

        if ($len(%gpg.line) == 0) {
          set %gpg.line ~
          msg $active Comment: mirc-gpg by GeekShed.net version %gpg.scriptver http://mirc-gpg.googlecode.com
          set %gpg.body 1
        }
        if (%gpg.line == -----END PGP MESSAGE-----) {
          msg $active %gpg.outmsg
          unset %gpg.outmsg
          unset %gpg.body
        }

        if (%gpg.body == 1) {
          if ($len(%gpg.outmsg) >= 385) {
            msg $active %gpg.outmsg
            unset %gpg.outmsg
            set %gpg.outmsg %gpg.line
          } 
          elseif ($len(%gpg.outmsg) == 0) {
            set %gpg.outmsg %gpg.line
          }
          else {
            set %gpg.outmsg %gpg.outmsg $+ ! $+ %gpg.line
          }
        } 
        else {
          msg $active %gpg.line
        }
        inc %gpg.i
      }

      if ($len(%gpg.outmsg) > 0) {
        msg $active %gpg.outmsg
        unset %gpg.outmsg
      }
      unset %gpg.body
    }

    if (%gpg.editbox != $null) {
      echo -at < $+ $me [UNENC]> 4 $+ %gpg.editbox
      unset %gpg.editbox
    }

    unset %gpg.halt

    runapphidden cmd /c del " $+ $scriptdir $+ gpg\*" /Q
  }
}

alias gpgDecrypt {
  set %gpg.destfile $4- $+ .unenc
  runappmin cmd /c gpg -d -o " $+ %gpg.destfile $+ " " $+ $4- $+ " 2> " $+ $4- $+ .out $+ "

  .timergpg $+ . $+ $3 $+ . $+ $2 off

  if (!$isfile(%gpg.destfile)) {
    echo $2 $timestamp < $+ $1 [ERROR]> 4This message may not have been for you
  }
  else {
    set %gpg.i 1

    while (%gpg.i <= $lines($4- $+ .unenc)) {
      set %gpg.readline $read($4- $+ .unenc, %gpg.i)
      if ($len(%gpg.readline) > 0) {
        echo $2 $timestamp < $+ $1 [UNENC]> 4 $+ $strip(%gpg.readline)
      }
      else {
        echo $2 $timestamp < $+ $1 $+ [UNENC]> 4 $+ $chr(1)
      }
      inc %gpg.i
    }

    runapphidden cmd /c del " $+ $4- $+ *" /Q
  }
}

alias addKeysToSPK {
  set %gpg.keyfile $scriptdir $+ gpg\keylist.txt

  if ($1 == $null) {
    runapphidden cmd /c gpg --list-keys > " $+ %gpg.keyfile $+ "
  }
  else {
    runapphidden cmd /c gpg --list-keys " $+ $1- $+ " > " $+ %gpg.keyfile $+ "
  }

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
  if (%gpg.searchstr == $null) {
    addKeysToSPK
  }
  else {
    addKeysToSPK %gpg.searchstr
    did -a spk 4 %gpg.searchstr
  }
}

on *:dialog:spk:sclick:*:{
  if ($did == 3) {
    set %gpg.halt 1
  }
  elseif ($did == 5) {
    did -r spk 1
    set %gpg.searchstr $did(4).text
    addkeystospk %gpg.searchstr
  }
  elseif ($did == 2) {
    if ($did(1, 0).sel == 0) {
      echo -at No key was selected
      set %gpg.halt 1
    }
    else {
      set %gpg.i 1
      set %gpg.recipients $null

      while (%gpg.i <= $did(1).lines) {
        if ($did(1, %gpg.i).cstate == 1 || $did(1, %gpg.i).state == 1) {
          set %gpg.revitem $rev($did(1, %gpg.i))
          set %gpg.emailstart $pos(%gpg.revitem, >, 1)
          set %gpg.emailend $pos(%gpg.revitem, <, 1)

          set %gpg.recipients %gpg.recipients -r $rev($mid(%gpg.revitem, $calc(%gpg.emailstart + 1), $calc(%gpg.emailend - %gpg.emailstart - 1)))
        }

        inc %gpg.i
      }
    }
  }
  elseif ($did == 6) {
    set %gpg.i 1

    while (%gpg.i <= $did(1).lines) {
      if ($did(6).state == 1) {
        did -s spk 1 %gpg.i
      }
      else {
        did -l spk 1 %gpg.i
      }

      inc %gpg.i
    }
  }
  elseif ($did == 1) {
    set %gpg.i 1
    set %gpg.checkAll 1

    while (%gpg.i <= $did(1).lines) {
      if ($did(1, %gpg.i).cstate == 0) {
        set %gpg.checkAll 0
      }

      inc %gpg.i
    }

    if (%gpg.checkAll == 1) {
      did -c spk 6
    }
    else {
      did -u spk 6
    }
  }
}

dialog selPubKey {

  title "Select Public Key"

  size -1 -1 250 170

  option dbu

  edit "", 4, 10 10 190 10
  button "Search", 5, 205 8 35 14, default

  check "Select/Deselect All", 6, 12 25 100 10

  list 1, 10 37 230 100, multsel check result

  button "OK", 2, 65 142 50 20, ok %gpg.okbut
  button "Cancel", 3, 125 142 50 20, cancel %gpg.cancelbut
}

alias dodel {
  if (%gpg.textin. [ $+ [ $1 $+ .  [ $+ [ $2 ] ] ] ] == $null) {
    runapphidden cmd /c del " $+ $scriptdir $+ gpg\textin\ $+ $1 $+ - $+ $2 $+ .*" /Q
    .timergpg $+ . $+ $1 $+ . $+ $2 off
  }
  dec %gpg.incount 1
  if (%gpg.incount <= 0) {
    disable #gpg.capture
  }
}

#gpg on
on 1:TEXT:-----BEGIN PGP MESSAGE-----:*:{
  .enable #gpg.capture
  set -u10 %gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] 1
  write -c " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $1-
  .timergpg $+ . $+ $network $+ . $+ $nick 0 1 dodel $network $nick
  if (%gpg.incount < 0) {
    set %gpg.incount 0
  }
  inc %gpg.incount 1
}

on 1:TEXT:-----END PGP MESSAGE-----:*:{
  if (%gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] != $null) {
    .timergpg $+ . $+ $network $+ . $+ $nick off
    unset %gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ]
    write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $1-
  }
  dec %gpg.incount 1
  if (%gpg.incount <= 0) {
    .disable #gpg.capture
  }

  if ($chan != $null) {
    set %gpg.src $chan
  }
  else {
    set %gpg.src $nick
  }

  gpgdecrypt $nick %gpg.src $network $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg
}
#gpg end

#gpg.capture off
on 1:TEXT:*:*:{
  if ($1 != -----END PGP MESSAGE-----) {
    if (%gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] != $null) {
      set -u10 %gpg.textin. [ $+ [ $network $+ .  [ $+ [ $nick ] ] ] ] 1
      if ($pos($1-,!,0) > 0) {
        write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $replace($replace($1-,~!,$chr(10)),!,$chr(10))
      }
      elseif ($1- != ~) {
        write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $1-
      }
      else {
        write " $+ $scriptdir $+ gpg\textin\ $+ $network $+ - $+ $nick $+ .txt.gpg $+ " $chr(13)
      }
    }
  }
}
#gpg.capture end

alias rev {
  if ($1) {
    set %gpg.c $strip($1-)
    set %gpg.a $len(%gpg.c)
    while (%gpg.a >= 1) {
      set %gpg.b %gpg.b $+ $replace($mid(%gpg.c,%gpg.a,1),$chr(32),$str($chr(32),2))
      dec %gpg.a
    }
  }
  set %gpg.o %gpg.b
  unset %gpg.a
  unset %gpg.b
  unset %gpg.c
  return %gpg.o
}
