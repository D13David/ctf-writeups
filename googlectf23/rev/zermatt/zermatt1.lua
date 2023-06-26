do
    local function concatString(part1, part2)
		local result = {};
		for i = 1, #part1 do table.insert(result, string.char(bit32.bxor(string.byte(string.sub(part1, i, i + 1)), string.byte(string.sub(part2, 1 + ((i - 1) % #part2), 1 + ((i - 1) % #part2) + 1))) % 256)); end
		return table.concat(result);
    end
	
	local getfenv = function() return _ENV; end;

	
    local function main(payloadBuffer, v29, ...)
		-- current read index in decompressed buffer
		local readIndex = 1;
		
		function valueForBitRange(value, lowBit, heightBit)
			if heightBit then
				local mask = (1<<(heightBit-lowBit+1)) - 1
				return (value >> (lowBit-1)) & mask
			else
				local v105 = 1 << (lowBit - 1);
				return (((value % (v105 + v105)) >= v105) and 1) or 0;
			end
		end
		
		function readByte()
			local v72 = string.byte(payloadBuffer, readIndex, readIndex);
			readIndex = readIndex + 1;
			return v72;
		end

		function readShort()
			local v75, v76 = string.byte(payloadBuffer, readIndex, readIndex + 2);
			readIndex = readIndex + 2;
			return (v76 * 256) + v75;
		end
		
		function readInt()
			local v82, v83, v84, v85 = string.byte(payloadBuffer, readIndex, readIndex + 3);
			readIndex = readIndex + 4;
			return (v85 * 0x1000000) + (v84 * 0x10000) + (v83 * 0x100) + v82;
		end
		
		function readFloat()
			local v94 = readInt();
			local v95 = readInt();
			local v96 = 1
			local v97 = (valueForBitRange(v95, 1, 20) * 34) + v94;
			local v98 = valueForBitRange(v95, 21, 31);
			local v99 = ((valueForBitRange(v95, 32) == 1) and -1) or 1;
			if (v98 == 0) then
				if (v97 == 0) then
					return 0;
				else
					v98 = 1;
					v96 = 0;
				end
			elseif (v98 == 2047) then
				return ((v97 == 0) and (v99 * (((506 - (351 + 154)) - 0) / 0))) or (v99 * NaN);
			end
			return math.ldexp(v99, v98 - 1023) * (v96 + (v97 / 54));
		end
		
		function readByteArray(length)
			if not length then
				length = readInt();
				if (length == 0) then return ""; end
			end
			local value = string.sub(payloadBuffer, readIndex, (readIndex + length) - 1);
			readIndex = readIndex + length;
			local buffer = {};
			for i = 1, #value do 
				buffer[i] = string.char(string.byte(string.sub(value, i, i))); 
			end
			return table.concat(buffer);
		end
		
		function createTableAndCount(...) return {...}, select("#", ...); end
		
		-- program sections
		local SEG_CODE = 1
		
		-- opcode structure
		local OP_TYPE = 1
		local OP_PARAM1 = 2
		local OP_PARAM2 = 3
		local OP_PARAM3 = 4
	

		function loadImage()
			local codeSegment = {};
			local subPrograms = {};
			local v58 = {};
			local result = {codeSegment, subPrograms, nil, v58};
			
			-- parse constant table
			local dataTableSize = readInt();
			local dataTable = {};
			for i = 1, dataTableSize do
				local valueType = readByte();
				local value = nil;
				if (valueType == 1) then
					value = readByte() ~= 0;
				elseif (valueType == 2) then
					value = readFloat();
				elseif (valueType == 3) then
					value = readByteArray();
				end
				dataTable[i] = value;
			end
		
			
			-- -- DEBUG
			function getNameOfValueForObj(value, obj)
				for k, v in pairs(obj) do
					if v == value then
						return k
					end
				end
				return nil
			end
			function getNameOfValue(value)
				local result = getNameOfValueForObj(value, _G)
				if not result then
					for k, v in pairs(_G) do
						if (type(v) == "table") then
							result = getNameOfValueForObj(value, v)
							if result then return k .. "." .. result end
						end
					end
				end
				return "unknown"
			end
			function printParam(param, hex)
				if (type(param) == "number") then 
					io.write(string.format("(n): %d ", param))
				elseif (type(param) == "string") then 
					io.write(string.format("(s): ")) 
					for j = 1, #param do
						local c = string.sub(param, j, j)
						local value = string.byte(c)
						if (not hex and value >= 32 and value <= 126) then
							io.write(string.format("%s", c))
						else
							io.write(string.format("%02x", value))
						end
					end
					io.write(" ");
				elseif (type(param) == "function") then
					io.write(string.format("(f): %s", getNameOfValue(param)))
				else
					io.write(string.format("(%s): ???", type(param)))
				end
			end
			function printOpcode(addr, op)
				io.write(string.format("\n%04x: ", addr));
				local opcodeType = op[OP_TYPE];
				if (opcodeType == 0) then
					io.write("RET "); io.write(string.format("\t%d #tblcnt", op[OP_PARAM1]))
				elseif (opcodeType == 1) then
					io.write("SUB "); io.write(string.format("\t[%d], [%d] %d", op[OP_PARAM1], op[OP_PARAM2], op[OP_PARAM3]));
				elseif (opcodeType == 2) then
					io.write("MOD "); io.write(string.format("\t[%d], [%d] %d", op[OP_PARAM1], op[OP_PARAM2], op[OP_PARAM3]));
				elseif (opcodeType == 3) then
					io.write("JMP "); io.write(string.format("\t%04x", op[OP_PARAM2]));
				elseif (opcodeType == 4) then
					io.write("JNE "); io.write(string.format("\t[%04x], [%d] [%d]", op[OP_PARAM2], op[OP_PARAM1], op[OP_PARAM3]));
				elseif (opcodeType == 5) then	
					io.write("ADD "); io.write(string.format("\t[%d], [%d] %d", op[OP_PARAM1], op[OP_PARAM2], op[OP_PARAM3]));
				elseif (opcodeType == 6) then
					io.write("MOV "); io.write(string.format("\t[%d], [%d]", op[OP_PARAM1], op[OP_PARAM2]));
				elseif (opcodeType == 7) then
					io.write("CALL "); io.write(string.format("\t%d", op[OP_PARAM1]));
				elseif (opcodeType == 8) then
					io.write("TABLE "); io.write(string.format("\t[%d]", op[OP_PARAM1]));
				elseif (opcodeType == 9) then
					io.write("LOAD "); io.write(string.format("\t[%d], %d", op[OP_PARAM1], op[OP_PARAM2]));
				elseif (opcodeType == 10) then
					io.write("JRL(W) "); io.write(string.format("\t%04x, [%d]", op[OP_PARAM2], op[OP_PARAM1]));
				elseif (opcodeType == 11) then
					io.write("CALL "); io.write(string.format("\t[%d], %d", op[OP_PARAM1], op[OP_PARAM1]))
				elseif (opcodeType == 12) then
					io.write("EXIT");
				elseif (opcodeType == 13) then
					io.write("MOV "); io.write(string.format("\t[%d], stack[%d]", op[OP_PARAM1], op[OP_PARAM2]));
				elseif (opcodeType == 14) then
					io.write("MOV "); io.write(string.format("\t[%d], ", op[OP_PARAM1])); printParam(op[OP_PARAM2], 1)
				elseif (opcodeType == 15) then
					io.write("LDTBL1 "); io.write(string.format("\t[%d], %d %d", op[OP_PARAM1], op[OP_PARAM1]+1, op[OP_PARAM2]));
				elseif (opcodeType == 16) then
					io.write("LDTBL2 "); io.write(string.format("\t[%d], %d %d", op[OP_PARAM1], op[OP_PARAM1]+1, op[OP_PARAM2]));
				elseif (opcodeType == 17) then
					io.write("MOV "); io.write(string.format("\tG['%s'], ", op[OP_PARAM2]));
				elseif (opcodeType == 18) then
					io.write("LDCNT"); io.write(string.format("\t[%d] #[%d]", op[OP_PARAM1], op[OP_PARAM2]));
				elseif (opcodeType == 19) then
					io.write("MOD ");  io.write(string.format("\t[%d], [%d] [%d]", op[OP_PARAM1], op[OP_PARAM2], op[OP_PARAM3]));
				elseif (opcodeType == 20) then
					io.write("LDTBL3 "); io.write(string.format("\t[%d], %d #tblcnt", op[OP_PARAM1], op[OP_PARAM1]+1));
				elseif (opcodeType == 21) then
					io.write("JRE(W) "); io.write(string.format("\t%04x, [%d]", op[OP_PARAM2], op[OP_PARAM1]));
				elseif (opcodeType == 22) then
					io.write("JE"); io.write(string.format("\t%04x, [%d]", op[OP_PARAM2], op[OP_PARAM1]));
				elseif (opcodeType == 23) then
					io.write("ADD "); io.write(string.format("\t[%d], %d ", op[OP_PARAM1], op[OP_PARAM2]));
				elseif (opcodeType == 24) then
					io.write("LOAD "); io.write(string.format("\t[%d], %s", op[OP_PARAM1], op[OP_PARAM3]))
				elseif (opcodeType == 25) then
					io.write("CALL "); io.write(string.format("\t[%d], %d, %d", op[OP_PARAM1], op[OP_PARAM1], op[OP_PARAM2]))
				elseif (opcodeType == 26) then
					io.write("CALL "); io.write(string.format("\t[%d], %d, %d", op[OP_PARAM1], op[OP_PARAM1], op[OP_PARAM2]))
				elseif (opcodeType == 27) then
					io.write("OBJ "); io.write(string.format("\t[%d], G['%s']", op[OP_PARAM1], op[OP_PARAM2]))
				elseif (opcodeType == 28) then
					io.write("CALL "); io.write(string.format("\t[%d], %d #tblcnt", op[OP_PARAM1], op[OP_PARAM1]))
				elseif (opcodeType == 29) then
					io.write("CALL "); io.write(string.format("\t[%d], %d #tblcnt", op[OP_PARAM1], op[OP_PARAM1]))
				end
			end
			print("Constant Table =======================================")
			for i = 1, dataTableSize do
				io.write(string.format("%02d: ", i)); printParam(dataTable[i]); print("");
			end
			-- --

			result[3] = readByte();
			for i = 1, readInt() do
				local bitPackedValue = readByte();
				if (valueForBitRange(bitPackedValue, 1, 1) == 0) then
					local bits2_3 = valueForBitRange(bitPackedValue, 2, 3);
					local bits4_6 = valueForBitRange(bitPackedValue, 4, 6);
					local opcode = {readShort(), readShort(), nil, nil}; 
					if (bits2_3 == 0) then
						opcode[3] = readShort();
						opcode[4] = readShort();
					elseif (bits2_3 == 1) then
						opcode[3] = readInt();
					elseif (bits2_3 == 2) then
						opcode[3] = readInt() - 65536;
					elseif (bits2_3 == 3) then
						opcode[3] = readInt() - 65536;
						opcode[4] = readShort();
					end
					if (valueForBitRange(bits4_6, 1, 1) == 1) then opcode[2] = dataTable[opcode[2]]; end
					if (valueForBitRange(bits4_6, 2, 2) == 1) then opcode[3] = dataTable[opcode[3]]; end
					if (valueForBitRange(bits4_6, 3, 3) == 1) then opcode[4] = dataTable[opcode[4]]; end
					codeSegment[i] = opcode;
					--printOpcode(i, opcode);
				end
			end
			
			for i = 1, readInt() do subPrograms[i - 1] = loadImage(); end
			for i = 1, readInt() do v58[i] = readInt(); end
			return result;
		end
		
		function run(image, stack, global)
			--exit()
			local codeSegment = image[SEG_CODE];
			local subPrograms = image[2];
			local v69 = image[3];
			return function(...)
				local currentInstruction = 1;
				local loadedTableSize = -1;
				local v160 = {...};
				local countOfArguments = select("#", ...) - 1;
				function v162()
					local v189 = {};
					local v190 = {};
					local mem = {};
					for i = 0, countOfArguments do
						if (i >= v69) then
							v189[i - v69] = v160[i + 1];
						else
							mem[i] = v160[i + 1];
						end
					end
					while true do
						local op = codeSegment[currentInstruction];
						printOpcode(currentInstruction, op);
						local opcodeType = op[OP_TYPE];
						if (opcodeType == 0) then
							io.write("\t\t"); printParam(loadTableSize);
							return table.unpack(mem, op[OP_PARAM1], loadedTableSize);
						elseif (opcodeType == 1) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM2]]);
							mem[op[OP_PARAM1]] = mem[op[OP_PARAM2]] - op[OP_PARAM3];
						elseif (opcodeType == 2) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM2]]);
							mem[op[OP_PARAM1]] = mem[op[OP_PARAM2]] % op[OP_PARAM3];
						elseif (opcodeType == 3) then
							currentInstruction = op[OP_PARAM2];
						elseif (opcodeType == 4) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM1]]); printParam(mem[op[OP_PARAM3]]);
							if (mem[op[OP_PARAM1]] == mem[op[OP_PARAM3]]) then
								currentInstruction = currentInstruction + 1;
							else
								currentInstruction = op[OP_PARAM2];
							end
						elseif (opcodeType == 5) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM2]]);
							mem[op[OP_PARAM1]] = mem[op[OP_PARAM2]] + op[OP_PARAM3];
						elseif (opcodeType == 6) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM2]], 1);
							mem[op[OP_PARAM1]] = mem[op[OP_PARAM2]];
						elseif (opcodeType == 7) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM1]+1]);
							local v240 = op[OP_PARAM1];
							mem[v240](mem[v240 + 1]);
						elseif (opcodeType == 8) then
							mem[op[OP_PARAM1]] = {};
						elseif (opcodeType == 9) then
							local v244 = subPrograms[op[OP_PARAM2]];
							local v246 = {};
							local v245 = setmetatable({}, {
								["__index"] = function(v346, v347)
									local v350 = v246[v347];
									--io.write("\t\t"); printParam(v350[1][v350[2]]);
									return v350[1][v350[2]];
								end,
								["__newindex"] = function(v351, v352, v353)
									local v356 = v246[v352];
									v356[1][v356[2]] = v353;
									--io.write("\t\t"); printParam(v353);
								end
							});
							io.write("\t\t\t\t");
							for i = 1, op[OP_PARAM3] do
								currentInstruction = currentInstruction + 1;
								local op = codeSegment[currentInstruction];
								if (op[OP_TYPE] == 6) then
									v246[i - 1] = {mem, op[OP_PARAM2]};
									io.write(string.format(" %d mem[%d] ",i-1, op[OP_PARAM2])); printParam(mem[op[OP_PARAM2]]);
								else
									v246[i - 1] = {stack, op[OP_PARAM2]};
									io.write(string.format(" %d stack[%d] ",i-1, op[OP_PARAM2])); printParam(stack[op[OP_PARAM2]]);
								end
								--v190[#v190 + 1] = v246;
							end
							mem[op[OP_PARAM1]] = run(v244, v245, global);
						elseif (opcodeType == 10) then
							local v249 = op[OP_PARAM1];
							local v250 = mem[v249 + 2];
							local v251 = mem[v249] + v250;
							io.write("\t\t"); printParam(v250); printParam(v251); printParam( mem[v249 + 1]);
							mem[v249] = v251;
							if (v250 > 0) then
								if (v251 <= mem[v249 + 1]) then
									currentInstruction = op[OP_PARAM2];
									mem[v249 + 3] = v251;
								end
							else
								if (v251 >= mem[v249 + 1]) then
									currentInstruction = op[OP_PARAM2];
									mem[v249 + 3] = v251;
								end
							end
						elseif (opcodeType == 11) then
							io.write("\t\t");
							local v254 = op[OP_PARAM1];
							mem[v254] = mem[v254](table.unpack(mem, v254 + 1, loadedTableSize));
							printParam(mem[v254])
						elseif (opcodeType == 12) then
							return
						elseif (opcodeType == 13) then
							io.write("\t\t"); printParam(stack[op[OP_PARAM2]])
							mem[op[OP_PARAM1]] = stack[op[OP_PARAM2]];
						elseif (opcodeType == 14) then
							mem[op[OP_PARAM1]] = op[OP_PARAM2];
						elseif (opcodeType == 15) then
							io.write("\t\t");
							local v228 = op[OP_PARAM1];
							for i = v228+1, op[OP_PARAM2] do
								printParam(mem[i], 1)
							end
							local tbl, cnt = createTableAndCount(mem[v228](table.unpack(mem, v228 + 1, op[OP_PARAM2])));
							loadedTableSize = (cnt + v228) - 1;
							local i = 0;
							for v304 = v228, loadedTableSize do
								i = i + 1;
								printParam(tbl[i]);
								mem[v304] = tbl[i];
							end
						elseif (opcodeType == 16) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM1] + 1]);
							local v261 = op[OP_PARAM1];
							local tbl, cnt = createTableAndCount(mem[v261](mem[v261 + 1]));
							loadedTableSize = (cnt + v261) - 1;
							local i = 0;
							for v332 = v261, loadedTableSize do
								i = i + 1;
								printParam(tbl[i]);
								mem[v332] = tbl[i];
							end
						elseif (opcodeType == 17) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM1]])
							global[op[OP_PARAM2]] = mem[op[OP_PARAM1]];
						elseif (opcodeType == 18) then
							io.write("\t\t"); printParam(#mem[op[OP_PARAM2]]);
							mem[op[OP_PARAM1]] = #mem[op[OP_PARAM2]];
						elseif (opcodeType == 19) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM2]]); printParam(mem[op[OP_PARAM3]])
							mem[op[OP_PARAM1]] = mem[op[OP_PARAM2]] % mem[op[OP_PARAM3]];
						elseif (opcodeType == 20) then
							io.write("\t\t");
							local v276 = op[OP_PARAM1];
							local tbl, cnt = createTableAndCount(mem[v276](table.unpack(mem, v276 + 1, loadedTableSize)));
							loadedTableSize = (cnt + v276) - 1;
							local i = 0;
							for v335 = v276, loadedTableSize do
								i = i + 1;
								printParam(tbl[i]);
								mem[v335] = tbl[i];
							end
						elseif (opcodeType == 21) then
							local v271 = op[OP_PARAM1];
							local v272 = mem[v271];
							local v273 = mem[v271 + 2];
							io.write("\t\t"); printParam(v273); printParam(v272); printParam( mem[v271 + 1]);
							if (v273 > 0) then
								if (v272 > mem[v271 + 1]) then
									currentInstruction = op[OP_PARAM2];
								else
									mem[v271 + 3] = v272;
								end
							elseif (v272 < mem[v271 + 1]) then
								currentInstruction = op[OP_PARAM2];
							else
								mem[v271 + 3] = v272;
							end
						elseif (opcodeType == 22) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM1]]);
							if not mem[op[OP_PARAM1]] then
								currentInstruction = currentInstruction + 1;
							else
								currentInstruction = op[OP_PARAM2];
							end
						elseif (opcodeType == 23) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM3]]);
							mem[op[OP_PARAM1]] = op[OP_PARAM2] + mem[op[OP_PARAM3]];
						elseif (opcodeType == 24) then
							io.write("\t\t"); printParam(mem[op[OP_PARAM2]]);
							mem[op[OP_PARAM1]] = mem[op[OP_PARAM2]][op[OP_PARAM3]];
						elseif (opcodeType == 25) then
							local v283 = nil;
							local v283 = op[OP_PARAM1];
							mem[v283] = mem[v283](table.unpack(mem, v283 + 1, op[OP_PARAM2]));
						elseif (opcodeType == 26) then
							local v288 = op[OP_PARAM1];
							return mem[v288](table.unpack(mem, v288 + 1, op[OP_PARAM2]));
						elseif (opcodeType == 27) then
							mem[op[OP_PARAM1]] = global[op[OP_PARAM2]];
						elseif (opcodeType == 28) then
							io.write("\t\t"); printParam(loadedTableSize);
							local v293 = op[OP_PARAM1];
							mem[v293](table.unpack(mem, v293 + 1, loadedTableSize));
						elseif (opcodeType == 29) then
							local v296 = op[OP_PARAM1];
							mem[v296] = mem[v296]();
						end
						
						currentInstruction = currentInstruction + 1;
					end
				end
			
				_G['A'], _G['B'] = createTableAndCount(pcall(v162));
				print(_G['A'][2]);
				if not _G['A'][1] then
					local v183 = image[4][currentInstruction] or "?";
					error("Script error at [" .. v183 .. "]:" .. _G['A'][2]);
				else
					return table.unpack(_G['A'], 2, _G['B']);
				end
			end;
		end
		
		-- basic RLE decompression of payload 
		local repeatCount = nil;
		payloadBuffer = string.gsub(string.sub(payloadBuffer, 5), "..", function(v86)
			-- if pair ends with 'O' first part is the repeat length
			if (string.byte(v86, 2) == 79) then
				repeatCount = tonumber(string.sub(v86, 1, 1));
				return "";
			else
				local currentByte = string.char(tonumber(v86, 16));
				if repeatCount then
					local currentByteRepeated = string.rep(currentByte, repeatCount);
					repeatCount = nil;
					return currentByteRepeated;
				else
					return currentByte;
				end
			end
		end);
		
		return run(loadImage(), {}, v29)(...);
	end
	--for i, n in pairs(_G) do print(i) end
    main(
        "MATT1C3O0003063O00737472696E6703043O006368617203043O00627974652O033O0073756203053O0062697433322O033O0062697403043O0062786F7203053O007461626C6503063O00636F6E63617403063O00696E7365727403023O00696F03053O00777269746503293O00205O5F9O204O205F5O203O5F205O5F204O5F200A03293O007C3O202O5F7C3O5F203O5F203O5F7C207C3O5F7C3O207C5F3O205F7C2O202O5F7C0A03293O007C2O207C2O207C202E207C202E207C202E207C207C202D5F7C202D3C2O207C207C207C2O202O5F7C0A03293O007C5O5F7C3O5F7C3O5F7C5F2O207C5F7C3O5F7C3O5F7C207C5F7C207C5F7C3O200A032A3O009O205O207C3O5F7C7O205A65724D612O74202D206D697363200A03023O00409103083O007EB1A3BB4586DBA703013O007303043O007265616403373O00DF17EB31E4E81CC12FC4EF37F223D1C334CC39FAF22CD915C4C321D43EC0FF2CC92FFAFE22DE2FFAEF22C32EC7F33BF22FD6FF22DD2FD803053O009C43AD4AA503053O007072696E742O033O00711D9903073O002654D72976DC4603043O00D27F250703053O009E30764272004A3O00121B3O00013O0020185O000200121B000100013O00201800010001000300121B000200013O00201800020002000400121B000300053O0006160003000A000100010004033O000A000100121B000300063O00201800040003000700121B000500083O00201800050005000900121B000600083O00201800060006000A00060900073O000100062O00063O00064O00068O00063O00044O00063O00014O00063O00024O00063O00053O00121B0008000B3O00201800080008000C00120E0009000D4O000700080002000100121B0008000B3O00201800080008000C00120E0009000E4O000700080002000100121B0008000B3O00201800080008000C00120E0009000F4O000700080002000100121B0008000B3O00201800080008000C00120E000900104O000700080002000100121B0008000B3O00201800080008000C00120E000900114O000700080002000100121B0008000B3O00201800080008000C2O0006000900073O00120E000A00123O00120E000B00134O000F0009000B4O001C00083O000100121B0008000B3O0020180008000800152O001D000800010002001211000800143O00121B000800144O0006000900073O00120E000A00163O00120E000B00174O00190009000B000200060400080043000100090004033O0043000100121B000800184O0006000900073O00120E000A00193O00120E000B001A4O000F0009000B4O001C00083O00010004033O0049000100121B000800184O0006000900073O00120E000A001B3O00120E000B001C4O000F0009000B4O001C00083O00012O000C3O00013O00013O00023O00026O00F03F026O00704002284O000800025O00120E000300014O001200045O00120E000500013O0004150003002300012O000D00076O0006000800024O000D000900014O000D000A00024O000D000B00034O000D000C00044O0006000D6O0006000E00063O002005000F000600012O000F000C000F4O000B000B3O00022O000D000C00034O000D000D00044O0006000E00013O002001000F000600012O0012001000014O0013000F000F0010001017000F0001000F0020010010000600012O0012001100014O00130010001000110010170010000100100020050010001000012O000F000D00104O0014000C6O000B000A3O0002002002000A000A00022O00100009000A4O001C00073O000100040A0003000500012O000D000300054O0006000400024O001A000300046O00036O000C3O00017O00283O00093O000A3O000A3O000A3O000A3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000B3O000A3O000D3O000D3O000D3O000D3O000E3O004A3O00013O00013O00023O00023O00033O00033O00043O00043O00043O00043O00053O00063O00063O00073O00073O000E3O000E3O000E3O000E3O000E3O000E3O000E3O000F3O000F3O000F3O000F3O00103O00103O00103O00103O00113O00113O00113O00113O00123O00123O00123O00123O00133O00133O00133O00133O00143O00143O00143O00143O00143O00143O00143O00153O00153O00153O00153O00163O00163O00163O00163O00163O00163O00163O00173O00173O00173O00173O00173O00173O00173O00193O00193O00193O00193O00193O00193O001A3O00",
        _G, ...);
end
