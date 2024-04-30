# AirOverflow CTF 2024

## Keygen

> I wrote a commercially acceptable license checker. No keygen exists for it.
>
>  Author: TheFlash2k
>
> [`keygen.tar`](keygen.tar)

Tags: _rev_

## Solution
The challenge comes with a binary we put to `Ghidra`. The main function gives us some bad `c++` vibes (but behind the noise its not that complicated to read actually).

```cpp
undefined8 main(void)
{
  char cVar1;
  basic_ostream *pbVar2;
  long in_FS_OFFSET;
  basic_string local_68 [32];
  basic_string local_48 [40];
  long local_20;
  
  local_20 = *(long *)(in_FS_OFFSET + 0x28);
  std::__cxx11::basic_string<>::basic_string();
                    /* try { // try from 00102e39 to 00102e63 has its CatchHandler @ 00102f23 */
  std::operator<<((basic_ostream *)std::cout,"Enter the license key: ");
  std::getline<>((basic_istream *)std::cin,local_68);
  std::__cxx11::basic_string<>::basic_string(local_48);
                    /* try { // try from 00102e6b to 00102e6f has its CatchHandler @ 00102f0e */
  cVar1 = check(SUB81(local_48,0));
  std::__cxx11::basic_string<>::~basic_string((basic_string<> *)local_48);
  if (cVar1 == '\0') {
    pbVar2 = std::operator<<((basic_ostream *)std::cout,"Invalid license");
    std::basic_ostream<>::operator<<((basic_ostream<> *)pbVar2,std::endl<>);
  }
  else {
                    /* try { // try from 00102e90 to 00102eeb has its CatchHandler @ 00102f23 */
    pbVar2 = std::operator<<((basic_ostream *)std::cout,"Good job!");
    std::basic_ostream<>::operator<<((basic_ostream<> *)pbVar2,std::endl<>);
    std::operator<<((basic_ostream *)std::cout,"Flag: ");
    print_flag();
  }
  std::__cxx11::basic_string<>::~basic_string((basic_string<> *)local_68);
  if (local_20 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

Its just a small license checker. The user does input the license key, and the code calls `check` for validation. With a correct license key we are provided with the flag. Sadly `print_flag` reads the flag from a text file, so we cannot just grab the flag but have to give the server a valid license key. Lets see what `check` is doing:

```cpp
undefined8 check(basic_string param_1)

{
  bool bVar1;
  __type _Var2;
  undefined8 uVar3;
  undefined7 in_register_00000039;
  basic_string<> *this;
  long in_FS_OFFSET;
  undefined8 local_58;
  undefined8 local_50;
  undefined1 *local_48;
  basic_string *local_40;
  basic_string local_38 [40];
  long local_10;
  
  this = (basic_string<> *)CONCAT71(in_register_00000039,param_1);
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  swapper(local_38);
  std::__cxx11::basic_string<>::operator=(this,local_38);
  std::__cxx11::basic_string<>::~basic_string((basic_string<> *)local_38);
  swapper2(local_38);
  std::__cxx11::basic_string<>::operator=(this,local_38);
  std::__cxx11::basic_string<>::~basic_string((basic_string<> *)local_38);
  local_48 = valid_licences;
  local_58 = std::vector<>::begin((vector<> *)valid_licences);
  local_50 = std::vector<>::end((vector<> *)local_48);
  do {
    bVar1 = __gnu_cxx::operator!=((__normal_iterator *)&local_58,(__normal_iterator *)&local_50);
    if (!bVar1) {
      uVar3 = 0;
LAB_00102ded:
      if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
        __stack_chk_fail();
      }
      return uVar3;
    }
    local_40 = (basic_string *)
               __gnu_cxx::__normal_iterator<>::operator*((__normal_iterator<> *)&local_58);
    _Var2 = std::operator==((basic_string *)this,local_40);
    if ((char)_Var2 != '\0') {
      uVar3 = 1;
      goto LAB_00102ded;
    }
    __gnu_cxx::__normal_iterator<>::operator++((__normal_iterator<> *)&local_58);
  } while( true );
}
```

This calls `swapper` and `swapper2` on the input string and then walks a list of `valid_licenses` and checks if the modified input string can be found within the list. So our best bet would be to extract the list of valid licenses and hope we can generate a valid user input from this. We can see the license keys are initialized as static array, so we check where the array is written to and find `_static_initialization_and_destruction_0`, and there we have a whole bunch of license codes to work with:

```cpp
std::__cxx11::basic_string<>::basic_string
            ((char *)local_2b8,(allocator *)"ccb2f12a-a03c-47f6-9b89-dedbd2219287");
std::allocator<char>::allocator();
                /* try { // try from 0010301c to 00103020 has its CatchHandler @ 001037a3 */
std::__cxx11::basic_string<>::basic_string
            (local_298,(allocator *)"e0f9cb86-0678-4e07-b423-c18adceeae20");
std::allocator<char>::allocator();
                /* try { // try from 0010304f to 00103053 has its CatchHandler @ 0010378b */
std::__cxx11::basic_string<>::basic_string
            (local_278,(allocator *)"38d1187f-8047-4652-8bfa-b1021962b604");
std::allocator<char>::allocator();
                /* try { // try from 00103082 to 00103086 has its CatchHandler @ 00103773 */
std::__cxx11::basic_string<>::basic_string
            (local_258,(allocator *)"825ea97e-140c-4675-be64-f8834d4845e0");

...
```

So, one of them will do the job, lets just work with the first one: `ccb2f12a-a03c-47f6-9b89-dedbd2219287`. Lets now inspect `swapper` and `swapper2`.

```cpp
basic_string * swapper(basic_string *param_1)
{
  local_30 = *(long *)(in_FS_OFFSET + 0x28);
  local_c8 = 0xd;
  local_c4 = 1;
  local_c0 = 6;
  local_bc = 0;
  local_b8 = 0x1b;
  local_b4 = 0xc;
  local_b0 = 0x15;
  local_ac = 0x1a;
  local_a8 = 0x17;
  local_a4 = 9;
  local_a0 = 0x20;
  local_9c = 0x19;
  local_98 = 0x18;
  local_94 = 0x1c;
  local_90 = 2;
  local_8c = 0x11;
  local_88 = 5;
  local_84 = 0x21;
  local_80 = 0x23;
  local_7c = 0x12;
  local_78 = 0xf;
  local_74 = 0x16;
  local_70 = 10;
  local_6c = 0xb;
  local_68 = 0x14;
  local_64 = 8;
  local_60 = 4;
  local_5c = 0x13;
  local_58 = 0x10;
  local_54 = 0x1f;
  local_50 = 0xe;
  local_4c = 3;
  local_48 = 0x1e;
  local_44 = 0x22;
  local_40 = 7;
  local_3c = 0x1d;
  std::allocator<>::allocator();
                    /* try { // try from 00102940 to 00102944 has its CatchHandler @ 001029c1 */
  std::unordered_map<>::unordered_map
            ((unordered_map<> *)local_148,(initializer_list)&local_c8,0x12,(hash *)0x0,&local_14a,
             &local_149);
  std::allocator<>::~allocator(local_108);
                    /* try { // try from 0010296c to 00102970 has its CatchHandler @ 001029fa */
  std::unordered_map<>::unordered_map((unordered_map<> *)local_108,local_148);
                    /* try { // try from 0010298c to 00102990 has its CatchHandler @ 001029e2 */
  base_swapper((unordered_map)param_1,(basic_string *)local_108);
  std::unordered_map<>::~unordered_map((unordered_map<> *)local_108);
  std::unordered_map<>::~unordered_map((unordered_map<> *)local_148);
  if (local_30 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return param_1;
}
```

This code inserts an array of integers to an `unordered_map` and then calls `base_swapper` with the map and the input string. The constructor called for unordered map takes a `initializer_list` with `pair` elements. In this case both integers, so we have a structure of `key, value, key value, ...`. 

```cpp
basic_string * base_swapper(unordered_map param_1,basic_string *param_2)
{
  bool bVar1;
  undefined8 *puVar2;
  char *pcVar3;
  char *pcVar4;
  undefined4 in_register_0000003c;
  basic_string *pbVar5;
  long in_FS_OFFSET;
  undefined8 local_40;
  undefined8 local_38;
  basic_string *local_30;
  undefined8 local_28;
  long local_20;
  
  pbVar5 = (basic_string *)CONCAT44(in_register_0000003c,param_1);
  local_20 = *(long *)(in_FS_OFFSET + 0x28);
  std::__cxx11::basic_string<>::basic_string(pbVar5);
  local_30 = param_2;
  local_40 = std::unordered_map<>::begin((unordered_map<> *)param_2);
  local_38 = std::unordered_map<>::end();
  while( true ) {
    bVar1 = std::__detail::operator!=
                      ((_Node_iterator_base *)&local_40,(_Node_iterator_base *)&local_38);
    if (!bVar1) break;
    puVar2 = (undefined8 *)std::__detail::_Node_iterator<>::operator*((_Node_iterator<> *)&local_40)
    ;
    local_28 = *puVar2;
                    /* try { // try from 00102709 to 00102725 has its CatchHandler @ 0010273f */
    pcVar3 = (char *)std::__cxx11::basic_string<>::operator[]((ulong)pbVar5);
    pcVar4 = (char *)std::__cxx11::basic_string<>::operator[]((ulong)pbVar5);
    std::swap<char>(pcVar4,pcVar3);
    std::__detail::_Node_iterator<>::operator++((_Node_iterator<> *)&local_40);
  }
  if (local_20 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return pbVar5;
}
```

The logic is straight forward, `base_swapper` iterates all elements of the given map and swaps the char indexed by an element key with the char indexed by the element value. So all we have to do is to grab the mapping and swap the values ourself. Thankfully `swapper2` does exactly the same thing, but with different mapping. So we have to start with the mapping of `swapper2` and then again with the mapping of `swapper`.

```python
$ cat foo.py
swapper = [0xd, 1, 6, 0, 0x1b, 0xc, 0x15, 0x1a, 0x17, 9, 0x20, 0x19, 0x18, 0x1c, 2, 0x11, 5, 0x21, 0x23, 0x12, 0xf, 0x16, 10, 0xb, 0x14, 8, 4, 0x13, 0x10, 0x1f, 0xe, 3, 0x1e, 0x22, 7, 0x1d]

swapper2 = [0x1a, 0x10, 8, 0x18, 0xe, 0x17, 0x11, 7, 5, 0x16, 0x1e, 0x13, 0x15, 0x1f, 0x1b, 2, 0x1d, 0x19, 0x20, 0x22, 0x14, 0x12, 3, 0x21, 10, 0xd, 0x23, 6, 9, 0xc, 0xb, 0, 4, 0x1c, 0xf, 1]

def swap(value, mapping):
    result = list(value)

    for i in range(0, len(mapping), 2):
        result[mapping[i]], result[mapping[i+1]] = result[mapping[i+1]], result[mapping[i]]

    return "".join(result)

lic = swap("ccb2f12a-a03c-47f6-9b89-dedbd2219287", swapper2)
lic = swap(lic, swapper)
print(lic)
```

```bash
$ nc challs.airoverflow.com 34546
Enter the license key: 70a-223e-4c-b7218b2ddfccf81a-69d299b
Good job!
Flag: AOFCTF{pr3d3f1n3d_k3y5_4nd_a_k3yg3N_eFadIP8e7J_lSzJKZif}
```

Flag `AOFCTF{pr3d3f1n3d_k3y5_4nd_a_k3yg3N_eFadIP8e7J_lSzJKZif}`