@rem I had to make this hack to allow me to include the export definitons, since I could find no way in the Dev-C++ GUI to do it.  There is probably something, but this works for now. :)

@path=%path%;c:\winapp\dev-cpp\bin
@dllwrap.exe -d mEnv.def --driver-name c++ --implib libmEnv.a dllmain.o mEnv_private.res -L"C:/WinApp/Dev-Cpp/lib" --no-export-all-symbols --add-stdcall-alias -o mEnv.dll