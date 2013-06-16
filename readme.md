mIRC GPG
========

Intro
-----

This is a fairly stable implementation of GPG in mIRC created by Phil Lavin and Allan Jude of GeekShed Ltd. (http://www.geekshed.net).
It comprises of a single mIRC script and integrates with the Windows binary of GPG (gpg.exe).

Instructions
------------

To use it, first set up GPG. Instructions for doing this can be found at http://www.tutorialnut.com/index.php/2010/03/28/getting-started-with-gpg-on-windows/ 

Once the script loads, you will be prompted with a box asking you to enter the path to GPG. Enter the correct path and click OK. 

If you followed the tutorial above you will have made a key with a pass phrase. Because you don't really want to be entering a pass phrase for each encrypted message you receive, you need to generate a key without a pass phrase. To do this, click the Commands menu at the top of mIRC and click mIRC-GPG->Generate a new Key. This will pop up a command window with the key generation process started. Answer the questions like so: 

Please select what kind of key you want: 1 

What keysize do you want? 1024 

Key is valid for? 0 

Is this correct? y 

Real name: Your Name 

Email address: your@email-address.com 

Comment: IRC Key 

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O 

You'll now be prompted for a passphrase twice. Just hit enter to use no passphrase. Your key will now be generated. You can use either the gpg command line or Cryptophane to send this key to a key server so other people can download it and send you messages. 

Now type a message in a channel or PM as you normally would however hit F8 rather than enter to send the message. You will be asked which key(s) you want to encrypt it with. Choose the key(s) of the intended recipient(s) and click OK. All being well the message should send. If any input is required (usually only happens if you haven't signed the key that you are encrypting with) the command prompt box will ask for it. 

On receiving a message which you can decrypt (i.e. it has been encrypted using your public key) it will be decrypted automatically and the decrypted form shown under the encrypted form. To prevent general annoyance, the command box for decrypting is started minimised and isn't focused. Usually the data will be decrypted and the command box closed. If it remains open it will be waiting for input (usually asking for a pass phrase if someone encrypted using one of your keys which requires a pass phrase). Just open it up from the taskbar manually and input the required data. 

If you find any bugs or have any requests, use the Issues tracker or ask in #help on irc.geekshed.net.

Condensed Instructions
------------

1. Follow the tutorial at http://www.tutorialnut.com/index.php/2010/03/28/getting-started-with-gpg-on-windows/ to get GPG set up
2. Copy gpg.mrc into the directory you normally place your mIRC scripts
3. Open your script editor by pressing Alt + R when in mIRC
4. Go to File->Load and locate gpg.mrc
5. You will be presented with a box asking for the directory path to gpg.exe. Browse to this and click OK.
6. Type some text in a channel as you normally would however instead of hitting enter to send the text, hit F8
7. Select the key(s) of the recipient(s) you want to be able to decrypt the message
8. Click OK

Inbound messages that you are able to decrypt will be decrypted automatically
