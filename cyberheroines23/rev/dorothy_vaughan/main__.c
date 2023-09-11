void MAIN__(void)
{
  int iVar1;
  int iVar2;
  long lVar3;
  undefined4 local_388;
  undefined4 local_384;
  char *local_380;
  undefined4 local_378;
  undefined4 *local_360;
  undefined8 local_350;
  char *local_348;
  char *local_340;
  char *local_338;
  undefined8 local_330;
  undefined4 local_258;
  char local_16f;
  char local_16e;
  undefined local_16d;
  undefined4 local_16c;
  undefined8 local_168;
  undefined8 local_160;
  undefined8 local_158;
  undefined8 local_150;
  undefined8 local_148;
  undefined8 local_140;
  undefined8 local_138;
  undefined8 local_130;
  undefined8 local_128;
  undefined8 local_120;
  undefined8 local_118;
  undefined8 local_110;
  undefined4 local_108;
  byte bStack249;
  undefined8 local_f8;
  undefined8 local_f0;
  undefined8 local_e8;
  undefined8 local_e0;
  undefined8 local_d8;
  undefined8 local_d0;
  undefined8 local_c8;
  undefined8 local_c0;
  undefined8 local_b8;
  undefined8 local_b0;
  undefined8 local_a8;
  undefined8 local_a0;
  undefined4 local_98;
  char cStack137;
  undefined8 local_88;
  undefined8 uStack128;
  undefined8 local_78;
  undefined8 uStack112;
  undefined8 local_68;
  undefined8 uStack96;
  undefined8 local_58;
  undefined8 uStack80;
  undefined8 local_48;
  undefined8 uStack64;
  undefined8 local_38;
  undefined8 uStack48;
  undefined4 local_28;
  int local_18;
  undefined4 local_14;
  uint local_10;
  uint local_c;
  
  local_380 = "dorothy.f90";
  local_378 = 9;
  local_16c = 0;
  local_360 = &local_16c;
  local_348 = "flag.txtold";
  local_350 = 8;
  local_340 = "old";
  local_338 = (char *)0x3;
  local_258 = 0;
  local_388 = 0x1000320;
  _gfortran_st_open(&local_388);
  if (local_16c != 0) {
    local_380 = "dorothy.f90";
    local_378 = 0xc;
    local_388 = 0x80;
    local_384 = 6;
    _gfortran_st_write(&local_388);
    _gfortran_transfer_character_write
              (&local_388,"Error opening input file \'flag.txt\'(A)Final Array:",0x23);
    _gfortran_st_write_done(&local_388);
    _gfortran_stop_string(0,0,0);
  }
  local_380 = "dorothy.f90";
  local_378 = 0x11;
  local_338 = "(A)Final Array:";
  local_330 = 3;
  local_388 = 0x1000;
  local_384 = local_14;
  _gfortran_st_read(&local_388);
  _gfortran_transfer_character(&local_388,&local_f8,100);
  _gfortran_st_read_done(&local_388);
  local_380 = "dorothy.f90";
  local_378 = 0x14;
  local_388 = 0;
  local_384 = local_14;
  _gfortran_st_close(&local_388);
  iVar2 = _gfortran_string_len_trim(100);
  local_18 = iVar2;
  local_168 = local_f8;
  local_160 = local_f0;
  local_158 = local_e8;
  local_150 = local_e0;
  local_148 = local_d8;
  local_140 = local_d0;
  local_138 = local_c8;
  local_130 = local_c0;
  local_128 = local_b8;
  local_120 = local_b0;
  local_118 = local_a8;
  local_110 = local_a0;
  local_108 = local_98;
  for (local_10 = 1; iVar1 = local_18, (int)local_10 <= iVar2; local_10 = local_10 + 1) {
    if ((&bStack249)[(int)local_10] == 0x7d || (&bStack249)[(int)local_10] == 0x7b) {
      *(byte *)((long)&local_16c + (long)(int)local_10 + 3) = (&bStack249)[(int)local_10];
    }
    else {
      if ((local_10 & 1) == 0) {
        local_c = (&bStack249)[(int)local_10] + 3;
      }
      else {
        local_c = (&bStack249)[(int)local_10] + 7;
      }
      local_16d = (undefined)local_c;
      *(undefined *)((long)&local_16c + (long)(int)local_10 + 3) = local_16d;
    }
  }
  local_88 = 0x2020202020202020;
  uStack128 = 0x2020202020202020;
  local_78 = 0x2020202020202020;
  uStack112 = 0x2020202020202020;
  local_68 = 0x2020202020202020;
  uStack96 = 0x2020202020202020;
  local_58 = 0x2020202020202020;
  uStack80 = 0x2020202020202020;
  local_48 = 0x2020202020202020;
  uStack64 = 0x2020202020202020;
  local_38 = 0x2020202020202020;
  uStack48 = 0x2020202020202020;
  local_28 = 0x20202020;
  for (local_10 = 1; (int)local_10 <= iVar1; local_10 = local_10 + 1) {
    local_c = (uint)*(byte *)((long)&local_16c + (long)(int)local_10 + 3);
    if (local_c < 0x5b && 0x40 < local_c) {
      local_16e = (char)(local_c - 0x2f) + (char)((int)(local_c - 0x2f) / 0x1a) * -0x1a + 'A';
      (&cStack137)[(int)local_10] = local_16e;
    }
    else if (local_c < 0x7b && 0x60 < local_c) {
      local_16f = (char)(local_c - 0x4f) + (char)((int)(local_c - 0x4f) / 0x1a) * -0x1a + 'a';
      (&cStack137)[(int)local_10] = local_16f;
    }
    else {
      (&cStack137)[(int)local_10] = *(char *)((long)&local_16c + (long)(int)local_10 + 3);
    }
  }
  local_380 = "dorothy.f90";
  local_378 = 0x35;
  local_388 = 0x80;
  local_384 = 6;
  _gfortran_st_write(0x2020202020202020,&local_388);
  _gfortran_transfer_character_write(&local_388,"Final Array:",0xc);
  lVar3 = 0;
  if (-1 < (long)local_18) {
    lVar3 = (long)local_18;
  }
  _gfortran_transfer_character_write(&local_388,&local_88,lVar3);
  _gfortran_st_write_done(&local_388);
  return;
}