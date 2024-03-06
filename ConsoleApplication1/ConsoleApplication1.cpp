// Proof of context rpg maker ruby runner.
// The define just allows us to use fopen instead of fopen_s
#define _CRT_SECURE_NO_WARNINGS
#include <Windows.h>
#include <iostream>
#include <direct.h>
#include <fstream>

// Definitions for the ruby functions we want to import.
typedef int* VALUE;
typedef void(__cdecl* f_ruby_init)();
typedef void(__cdecl* f_ruby_finalize)();
typedef VALUE(__cdecl* f_rb_eval_string)(const char* string);
typedef void(__cdecl* f_ruby_script)(const char* string);
typedef VALUE(__cdecl* f_rb_eval_string_protect)(const char* string, int* state);
typedef VALUE(__cdecl* f_rb_errinfo)();
typedef VALUE(__cdecl* f_rb_obj_as_string)(VALUE obj);

int main()
{
    // First off, load the loader ruby file. God, C++ is a cludge. TODO: Actually check that we managed to load it.
    FILE* f = fopen("loader.rb", "rb");
    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* loader = (char*)malloc(fsize + 1);
    fread(loader, fsize, 1, f);
    fclose(f);
    loader[fsize] = 0;
    // All that, just to load file contents.

    // Change the directory to the pokemon infinite fusion directory. TODO: Make it modular.
    _chdir("C:\\Users\\magnu\\Downloads\\pif\\InfiniteFusionGame");
    // Load the DLL file
    HINSTANCE hGetProcIDDLL = LoadLibraryA("x64-msvcrt-ruby300.dll");
    // We load all the dll functions...
    f_ruby_init ruby_init = (f_ruby_init)GetProcAddress(hGetProcIDDLL, "ruby_init");
    f_ruby_finalize ruby_finalize = (f_ruby_finalize)GetProcAddress(hGetProcIDDLL, "ruby_finalize");
    f_rb_eval_string rb_eval_string = (f_rb_eval_string)GetProcAddress(hGetProcIDDLL, "rb_eval_string");
    f_ruby_script ruby_script = (f_ruby_script)GetProcAddress(hGetProcIDDLL, "ruby_script");
    f_rb_eval_string_protect rb_eval_string_protect = (f_rb_eval_string_protect)GetProcAddress(hGetProcIDDLL, "rb_eval_string_protect");
    f_rb_errinfo rb_errinfo = (f_rb_errinfo)GetProcAddress(hGetProcIDDLL, "rb_errinfo");
    f_rb_obj_as_string rb_obj_as_string = (f_rb_obj_as_string)GetProcAddress(hGetProcIDDLL, "rb_obj_as_string");
    
    // FINALLY! Ruby time!
    ruby_init(); // Start ruby
    ruby_script("Hello"); // Set the script name to something.
    int test = 0; // This gets set to non-zero if there was a ruby error
    rb_eval_string_protect(loader, &test); // Run the loader code we had first thing in the file
    if (test != 0) // If there was an error..
        rb_eval_string("puts $!"); // Tell ruby to print it!
    ruby_finalize(); // Clean up
}