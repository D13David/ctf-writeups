# Full Weak Engineer CTF 2025

## I_HATE_DEBUGGING

> I hate debugging! Breakpoints, hooks - what are those, I don't get it! Can you help me out with some tech stuff?
>
>  Author: r_k01m
>
> [`I_HATE_DEBUGGING.zip`](I_HATE_DEBUGGING.zip)

Tags: _rev_

## Solution
After unpacking we find several files. There is the executable `antidebugtest.exe` which we need to reverse. There is also a DLL `whatisthis.dll` and a textfile `fakeflag.txt`, the latter containing a flag that obviously is not the flag we are looking for.

Opening the executable in `Binary Ninja`, we find the file is not stripped. That greatly helps with the analysis. The `main` function is relatively straight forward:

```c
140001eb4    int main()

140001eb4    {
140001eb4        __main();
140001ecc        BOOL rax;
140001ecc        rax = IsDebuggerPresent();
140001ecc        
140001ed1        if (!rax)
140001ed1        {
140001eff            hook();
140001f18            FILE* rax_2 = fopen("fakeflag.txt", u"r…");
140001f28            decodeflag(rax_2);
140001f34            fclose(rax_2);
140001f4d            FILE* _Stream;
140001f4d            int64_t r8_1;
140001f4d            _Stream = fopen("flag.txt", u"a…");
140001f64            __mingw_fprintf(_Stream, &memory, r8_1);
140001f70            fclose(_Stream);
140001ed1        }
140001ed1        else
140001ef6            MessageBoxA(nullptr, "DON'T USE DEBUG :)", "Error", MB_ICONHAND);
140001ef6        
140001f7f        return 0;
140001eb4    }
```

We already suspected by the challenge name, there are some anti debugging things in place. This is not really an issue, since we can just unpatch the calls if we feel the need to run this inside a debugger.

Otherwise the file opens `fakeflag.txt`, calls `decodeflag` with the handle to fakeflag.txt and finally closes the file. Then the progam opens `flag.txt` and writes the content of a global memory chunk (named `memory`) to the file. 

Looks like the program just decodes the flag? Maybe we just need to run it? But sadly enough the content of `flag.txt` looks not very promising after running the program.

Ok, we need to do some more work here. Let's check `decodeflag`:

```c
1400016d0    int decodeflag(struct _iobuf* file)

1400016d0    {
1400016d0        int64_t var_118;
1400016e7        __builtin_memset(&var_118, 0, 0x100);
140001811        char* rax;
140001811        rax = fgets(&var_118, 0x100, file);
140001811        
140001816        if (rax)
140001816        {
140001818            for (int32_t i = 0; i <= 6; i += 1)
14000185d                filetxt[(int64_t)i] = (int32_t)*(uint8_t*)(&var_118 + (int64_t)i);
140001816        }
140001816        
1400018dc        for (int32_t i_1 = 7; i_1 <= 0x30; i_1 += 1)
1400018dc        {
1400018dc            uint8_t rax_8 = memory[(int64_t)(i_1 - 6)];
1400018cb            filetxt[(int64_t)i_1] = ((uint32_t)(rax_8 << 5) | rax_8 >> 3) ^ 0x5a;
1400018dc        }
1400018dc        
1400018de        filetxt[0x30] = 0x7d;
1400018e8        filetxt[0x31] = 0;
1400018ff        return 0;
1400016d0    }
```

Well, this is not too bad. The function reads from the file handle (which is pointing to `fakeflag.txt` in that case) and stitches together the flag which is then contained in `filetxt` (another chunk of global memory) after the call. 

The first 7 characters coming from the fakeflag.txt file and correspond to the flag format prefix `fwectf{`. The character 49 is hardcoded to `}` and then the string is null-terminated.

Characters 8 - 48 are built by using hardcoded content (from `memory`), rotating the bits a bit and computing the rotated result with xor `0x5a`. This is easy stuff, we can just do this on our own.

The result is `fwectf{ml*oDejxljpdgpLpxgDuF>0!m_H07VI0!j}`... Well, that's probably not what we actually wanted. So let's inspect further...

There was the `hook` call we just skipped. There maaaybe something onto it, let's see.

```c
140001b96    int hook()

140001b96    {
140001b96        char var_29 = 0;
140001bc8        int32_t s_2;
140001bc8        *(uint32_t*)__builtin_memset(&s_2, 0, 0x60) = 0;
140001bce        __builtin_memcpy(&s_2, 
140001bce            "\xc3\x00\x00\x00\xd5\x00\x00\x00\xc4\x00\x00\x00\xc2\x00\x00\x00\xd4\x00\x00\x00\xd7\x00\x00\x00\xc5\x00\x00\x00\xd3\x00\x00\x00\x98\x00\x00\x00\xd2\x00\x00\x00\xda\x00\x00\x00\xda\x00\x00\x00", 
140001bce            0x30);
140001c60        int32_t s_1;
140001c60        *(uint32_t*)__builtin_memset(&s_1, 0, 0x60) = 0;
140001c66        __builtin_memcpy(&s_1, 
140001c66            "\xfd\x00\x00\x00\xf3\x00\x00\x00\xe4\x00\x00\x00\xf8\x00\x00\x00\xf3\x00\x00\x00\xfa\x00\x00\x00\xf4\x00\x00\x00\xf7\x00\x00\x00\xe5\x00\x00\x00\xf3\x00\x00\x00\x98\x00\x00\x00\xd2\x00\x00\x00\xda\x00\x00\x00\xda\x00\x00\x00", 
140001c66            0x38);
140001d09        int32_t s;
140001d09        *(uint32_t*)__builtin_memset(&s, 0, 0x60) = 0;
140001d0f        __builtin_memcpy(&s, 
140001d0f            "\xf5\x00\x00\x00\xc4\x00\x00\x00\xd3\x00\x00\x00\xd7\x00\x00\x00\xc2\x00\x00\x00\xd3\x00\x00\x00\xf0\x00\x00\x00\xdf\x00\x00\x00\xda\x00\x00\x00\xd3\x00\x00\x00\xe1\x00\x00\x00", 
140001d0f            0x2c);
140001d5c        int32_t var_30 = 1;
140001d66        int32_t var_34 = 1;
140001d70        int32_t var_38 = 1;
140001d7a        int32_t result = 0;
140001d7a        
140001e9f        while (true)
140001e9f        {
140001e9f            if (var_29 == 1)
140001ea5                return 1;
140001ea5            
140001dc8            char var_1a8[0xc];
140001dc8            
140001dc8            for (int32_t i = 0; i <= 0xb; i += 1)
140001dc8                var_1a8[(int64_t)i] = (char)(&s_2)[(int64_t)i] ^ result;
140001dc8            
140001e09            char var_1c8[0xe];
140001e09            
140001e09            for (int32_t i_1 = 0; i_1 <= 0xd; i_1 += 1)
140001e09                var_1c8[(int64_t)i_1] = (char)(&s_1)[(int64_t)i_1] ^ result;
140001e09            
140001e47            char var_1e8[0xb];
140001e47            
140001e47            for (int32_t i_2 = 0; i_2 <= 0xa; i_2 += 1)
140001e47                var_1e8[(int64_t)i_2] = (char)(&s)[(int64_t)i_2] ^ result;
140001e47            
140001e49            char var_19c_1 = 0;
140001e4d            char var_1ba_1 = 0;
140001e51            char var_1dd_1 = 0;
140001e51            
140001e82            if (iathook(&var_1a8, &var_1c8, &var_1e8, fb1, &originaldebug))
140001e82                break;
140001e82            
140001e8c            result += 1;
140001e9f        }
140001e9f        
140001e84        return result;
140001b96    }
```

This looks rather complicated and this calls `iathook` which is imported from `whatisthis.dll`. So let's first look at this function, maybe it clears up things a bit.

```c
2d31015a0    int64_t iathook(char const* arg1, char const* arg2, char const* arg3, int64_t (* (* arg4)())(), int64_t (** arg5)())

2d31015cc        uint32_t Size = 0
2d31015ec        uint8_t var_158[0x20]
2d31015ec        GetModuleFileNameA(hModule: nullptr, lpFilename: &var_158, nSize: 0x104)
2d31015ff        HMODULE Base = GetModuleHandleA(lpModuleName: arg1)
2d31015ff        
2d3101610        if (arg1 == 0)
2d3101620            GetModuleHandleA(lpModuleName: &var_158)
2d3101620        
2d3101649        int64_t (* rax_4)() =
2d3101649            GetProcAddress(hModule: GetModuleHandleA(lpModuleName: arg2), lpProcName: arg3)
2d3101660        *arg5 = rax_4
2d3101660        
2d310166b        if (rax_4 == 0)
2d310166d            return 0
2d310166d        
2d310169c        void* var_10_1 = ImageDirectoryEntryToData(Base, MappedAsImage: 1, 
2d310169c            DirectoryEntry: IMAGE_DIRECTORY_ENTRY_IMPORT, &Size)
2d310169c        
2d3101836        while (*(var_10_1 + 0xc) != 0)
2d31016be            void* var_38_1 = Base + zx.q(*(var_10_1 + 0xc))
2d31016db            int64_t (* (** lpAddress)())() = Base + zx.q(*(var_10_1 + 0x10))
2d31016f7            void* var_20_1 = Base + zx.q(*var_10_1)
2d31016f7            
2d310181c            while (*lpAddress != 0)
2d3101728                void* var_48_1 = Base + *var_20_1
2d3101728                
2d310173d                if (*lpAddress == rax_4)
2d310175e                    MEMORY_BASIC_INFORMATION buffer
2d310175e                    VirtualQuery(lpAddress, lpBuffer: &buffer, dwLength: 0x30)
2d3101787                    var_174
2d3101787                    BOOL rax_29
2d3101787                    rax_29.b = VirtualProtect(lpAddress: buffer.BaseAddress, 
2d3101787                        dwSize: buffer.RegionSize, flNewProtect: PAGE_EXECUTE_READWRITE, 
2d3101787                        lpflOldProtect: &var_174) == 0
2d3101787                    
2d310178c                    if (rax_29.b != 0)
2d31017b1                        MessageBoxA(hWnd: nullptr, 
2d31017b1                            lpText: "This is an error. If you did not…", 
2d31017b1                            lpCaption: "Error", uType: MB_ICONHAND)
2d31017b3                        return 0
2d31017b3                    
2d31017cb                    *lpAddress = arg4
2d31017f1                    enum PAGE_PROTECTION_FLAGS lpflOldProtect
2d31017f1                    BOOL rax_32
2d31017f1                    rax_32.b = VirtualProtect(lpAddress: buffer.BaseAddress, 
2d31017f1                        dwSize: buffer.RegionSize, flNewProtect: var_174.d, 
2d31017f1                        &lpflOldProtect) != 0
2d31017f1                    
2d31017f6                    if (rax_32.b != 0)
2d31017f8                        return 1
2d31017f8                
2d31017ff                lpAddress = &lpAddress[1]
2d3101807                var_20_1 += 8
2d3101807            
2d3101822            var_10_1 += 0x14
2d3101822        
2d310183c        return 0
```

This function, as the name suggested already, implements functionality to hook a function of a specific module. The first arguments are module name and function name and the last arguments are the callback and the pointer to the original function.

The function is called from `hook` which tries to camouflage the strings a bit. It's simple xor encryption and to avoid exposing the key the function loops over a set of values and tries to hook with the decrypted names. If the hook failed, the function just tries the next variant etc.

This is easy enough to crack, we can bruteforce the key, which is just a single byte and find `150` to be the correct value. This gives us `UCRTBASE.DLL`, `kernelbase.dll` and `cREATEfILEw` as first parameters. This means the program tries to hook `CreateFileW` from the loaded `kernelbase` module.

We also see the function callback passed in is stored in `fb1` and the program remembers the original function address in `originaldebug`. Now, `fb1` is not pointing anywhere, but we see it's statically initialized.

```c
140001f80    long long int (* (*)())() __static_initialization_and_destruction_0()

140001f80    {
140001f80        fa1 = 0x19eada7ef;
140001fa6        long long int (* (* result)())() = fa1 ^ 0xdeadbeef;
140001fa9        fb1 = result;
140001fb2        return result;
140001f80    }
```

This gives us `0x140001900` as address for our callback and we see the function at this address is suspiciously named `newopen`:

```c
140001900    int newopen(wchar_t const* filename, long unsigned int dwAccess, long unsigned int dwShareMode, 
140001900      struct _SECURITY_ATTRIBUTES* lpsecurity, long unsigned int dwCreatePosition, 
140001900      long unsigned int dwFlag, void* hTemplateFile)

140001900    {
140001900        long unsigned int dwAccess_1 = dwAccess;
14000190f        long unsigned int dwShareMode_1 = dwShareMode;
140001913        struct _SECURITY_ATTRIBUTES* lpsecurity_1 = lpsecurity;
140001922        BOOL rax;
140001922        rax = IsDebuggerPresent();
140001922        
140001927        if (rax)
140001927        {
140001941            Sleep(0x3e8);
140001937            return 0;
140001927        }
140001927        
140001941        int32_t var_20_1 = 1;
140001970        void* hTemplateFile_1 = hTemplateFile;
140001978        long unsigned int dwFlag_1 = dwFlag;
14000197f        long unsigned int dwCreatePosition_1 = dwCreatePosition;
140001986        return originaldebug();
140001900    }
```

Inspecting this function gives us not much at all. There is another anti debugging thingy and then the function just forwards to the original `CreateFileW`. That's weird, so we check the actual disassembly and find, there is actually a lot of more logic there:

```c
140001941  c745e801000000     mov     dword [rbp-0x18 {var_20_1}], 0x1
140001948  837de801           cmp     dword [rbp-0x18 {var_20}], 0x1  {0x0}
14000194c  7540               jne     0x14000198e

... snip

14000198e  c745fc00000000     mov     dword [rbp-0x4 {var_c_1}], 0x0
140001995  eb2c               jmp     0x1400019c3

140001997  8b45fc             mov     eax, dword [rbp-0x4 {var_c_1}]
14000199a  4898               cdqe    
14000199c  488d148500000000   lea     rdx, [rax*4]
1400019a4  488d05f5e60000     lea     rax, [rel filetxt]
1400019ab  8b0402             mov     eax, dword [rdx+rax]
1400019ae  89c1               mov     ecx, eax
1400019b0  8b45fc             mov     eax, dword [rbp-0x4 {var_c_1}]
1400019b3  4898               cdqe    
1400019b5  488d1564860000     lea     rdx, [rel memory]
1400019bc  880c10             mov     byte [rax+rdx], cl
1400019bf  8345fc01           add     dword [rbp-0x4 {var_c_1}], 0x1

... snip

```

Especially interesting is, that the logic works on `filetxt` and `memory` which we know are used for decoding the flag. The reason, why the decompiler just skipped this part are the first two lines. The program initializes a local variable with the value of `1` and jumps to `0x14000198e` only if the value is not equal to `1`. The decompiler tries to be smart here, skipping the part, since the condition will never be met.

Let's just patch this so the decompiler can do it's magic (by replacing `jne` with `je` or something alike).

```c
...
1400019c7        for (int32_t i = 0; i <= 0x31; i += 1)
1400019c7            memory[(int64_t)i] = (char)filetxt[(int64_t)i];
1400019c7        
140001a5e        for (int32_t i_1 = 0x23; i_1 <= 0x2f; i_1 += 1)
140001a5e        {
140001a5e            if (i_1 % 3)
140001a53                memory[(int64_t)i_1] = ((char)filetxt[(int64_t)i_1] ^ 0xd) + 4;
1400019fc            else
140001a23                memory[(int64_t)i_1] = (char)filetxt[(int64_t)i_1];
140001a5e        }
140001a5e        
140001aa0        for (int32_t i_2 = 7; i_2 <= 0xd; i_2 += 1)
140001aa0            memory[(int64_t)i_2] = (char)filetxt[(int64_t)i_2] ^ 0x5c;
140001aa0        
140001b15        for (int32_t i_3 = 0xe; i_3 <= 0x22; i_3 += 1)
140001b15        {
140001b15            if (i_3 & 1)
140001b0a                memory[(int64_t)i_3] = (char)filetxt[(int64_t)i_3] - 3;
140001ab3            else
140001add                memory[(int64_t)i_3] = (char)filetxt[(int64_t)i_3] - 0x11;
140001b15        }
140001b15        
140001b4b        for (int32_t i_4 = 0x31; i_4 > 6; i_4 -= 1)
140001b4b            memory[(int64_t)(i_4 + 1)] = memory[(int64_t)i_4];
140001b4b        
140001b4d        memory[7][0] = 0x49;
...
```

Ah, this is the missing part. This is where `memory` is filled with the unshuffled values of `filetxt`. Now, we can reimplement this in python (etc) or just patch our program to do the unshuffle properly. 

Actually, the challenge is about debugging and the program has an obvious bug. So let's fix it here.

We cannot just run this logic any time the function is called though, since `memory` contains content that is used in `decodeflag`. So we actually need to run this logic just before we write the `memory` content to our file *after* doing the `decode`. Since we fix hard to the programs context we just assume this is the second call to `CreateFileW`, so we need to fix the condition (which is currently `if (foo != 1)`) by storing the value somewhere in global memory.

Close to `memory` we find at address `0x1400104a0` a bool that is called `f`. The address is nowhere referenced, so we can just try to reuse it for our purpose. We have to replace these three lines with our own logic. Sadly, this is not much space, it's only 13 bytes we can use. 

```c
140001941  c745e801000000     mov     dword [rbp-0x18 {var_20_1}], 0x1
140001948  837de801           cmp     dword [rbp-0x18 {var_20}], 0x1  {0x0}
14000194c  7540               jne     0x14000198e
```

But actually, there is a lot of code just above, we don't really need. It's the anti debugging stuff, we'll just throw it away and get lots of space for our patched code.

```c
... snip

14000192a  90                 nop     
14000192b  90                 nop     
14000192c  90                 nop     
14000192d  90                 nop     
14000192e  8b056ceb0000       mov     eax, dword [rel f]
140001934  83f800             cmp     eax, 0x0
140001937  0f8551000000       jne     0x14000198e

14000193d  c70559eb00000100…  mov     dword [rel f], 0x1
140001947  90                 nop     
140001948  90                 nop     
140001949  90                 nop     
14000194a  90                 nop     
14000194b  90                 nop     
14000194c  90                 nop     
14000194d  90                 nop     
14000194e  488b0553eb0000     mov     rax, qword [rel originaldebug]
140001955  488945d8           mov     qword [rbp-0x28 {var_30_1}], rax

... snip
```

This gives us the following version for `newopen`:

```c
140001900    int newopen(wchar_t const* filename, long unsigned int dwAccess, long unsigned int dwShareMode, 
140001900      struct _SECURITY_ATTRIBUTES* lpsecurity, long unsigned int dwCreatePosition, long unsigned int dwFlag, void* hTemplateFile)

140001900    {
140001900        long unsigned int dwAccess_1 = dwAccess;
14000190f        long unsigned int dwShareMode_1 = dwShareMode;
14000190f        
140001937        if (!(*(uint32_t*)f))
140001937        {
14000198e            (*(uint32_t*)f) = true;
140001970            void* hTemplateFile_1 = hTemplateFile;
140001978            long unsigned int dwFlag_1 = dwFlag;
14000197f            long unsigned int dwCreatePosition_1 = dwCreatePosition;
140001986            return originaldebug();
140001937        }
140001937        
1400019c7        for (int32_t i = 0; i <= 0x31; i += 1)
1400019c7            memory[(int64_t)i] = (char)filetxt[(int64_t)i];
1400019c7        
140001a5e        for (int32_t i_1 = 0x23; i_1 <= 0x2f; i_1 += 1)
140001a5e        {
140001a5e            if (i_1 % 3)
140001a53                memory[(int64_t)i_1] = ((char)filetxt[(int64_t)i_1] ^ 0xd) + 4;
1400019fc            else
140001a23                memory[(int64_t)i_1] = (char)filetxt[(int64_t)i_1];
140001a5e        }
140001a5e        
140001aa0        for (int32_t i_2 = 7; i_2 <= 0xd; i_2 += 1)
140001aa0            memory[(int64_t)i_2] = (char)filetxt[(int64_t)i_2] ^ 0x5c;
140001aa0        
140001b15        for (int32_t i_3 = 0xe; i_3 <= 0x22; i_3 += 1)
140001b15        {
140001b15            if (i_3 & 1)
140001b0a                memory[(int64_t)i_3] = (char)filetxt[(int64_t)i_3] - 3;
140001ab3            else
140001add                memory[(int64_t)i_3] = (char)filetxt[(int64_t)i_3] - 0x11;
140001b15        }
140001b15        
140001b4b        for (int32_t i_4 = 0x31; i_4 > 6; i_4 -= 1)
140001b4b            memory[(int64_t)(i_4 + 1)] = memory[(int64_t)i_4];
140001b4b        
140001b4d        memory[7][0] = 0x49;
140001b76        void* hTemplateFile_2 = hTemplateFile;
140001b7e        long unsigned int dwFlag_2 = dwFlag;
140001b85        long unsigned int dwCreatePosition_2 = dwCreatePosition;
140001b8c        return originaldebug();
140001900    }
```

All we have to do now is to save the new version, run it and get the flag from `flag.txt`.

Flag `fwectf{I_10v3_D3bugging_and_I_und3r5700d_IA7_H00k}`