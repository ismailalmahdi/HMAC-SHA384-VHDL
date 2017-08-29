--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------???  ???????   ???? ??????  ??????????????????  ??? ??????---------------
-------???  ???????? ????????????????????????????????  ???????????--------------
-------??????????????????????????????     ????????????????????????--------------
-------??????????????????????????????     ????????????????????????--------------
-------???  ?????? ??? ??????  ??????????????????????  ??????  ???--------------
-------???  ??????     ??????  ??? ??????????????????  ??????  ???--------------
--------------------------------------------------------------------------------
------------------------???????  ?????? ???  ???--------------------------------
------------------------???????????????????  ???--------------------------------
-------------------------???????????????????????--------------------------------
-------------------------???????????????????????--------------------------------
------------------------????????????????     ???--------------------------------
------------------------???????  ??????------???--------------------------------
--------------------------------------------------------------------------------   
-----------???---???????---???????????????????????????---???--------------------
-----------???---????????--????????????????????????????--???--------------------
-----------???---?????????-??????---???---??????--??????-???--------------------
-----------???---????????????????---???---??????--??????????--------------------
-----------???????????? ?????????---???---??????????? ??????--------------------
------------??????? ???  ????????---???---???????????  ?????--------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.All;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
--///////////////////// PACKAGE HEADER STARTS HERE ///////////////////////////--
--------------------------------------------------------------------------------
	package HMACSHA384_ISMAIL is
		-----------------------
		-- Declare constants --
		-----------------------
		 constant block_size 	  :  integer  := 1024; 	--bits
		 constant word_size  	  :  integer 	:= 64;	 	--bits
		 constant rounds_number :  integer 	:= 80;		--bits
		 constant hashed_size  	:  integer 	:= 384;		--bits
		 constant length_bits   :  integer 	:= 128;		--bits
		 
		------------------------------
		-- Declare functions needed --
		------------------------------

		-- MESSAGE PADDING FUNCTION   
		function message_padding (message: std_logic_vector) 
		return std_logic_vector;
		-- GET MESSAGE BLOCK FUNCTION 
		function get_message_block (padded_message:std_logic_vector; block_number: integer) 
		return std_logic_vector;
		-- GET MESSAGE BLOCKS COUNT 
		function get_message_blocks_count(padded_message:std_logic_vector)
		return integer;

		


		---- F FUNCTION  
		function F_FUNCTION  (H : std_logic_vector (hashed_size - 1 downto 0);
		message_block: std_logic_vector (block_size - 1 downto 0) )
		return std_logic_vector;	

		-- F FUNCTION SUB FUNCTIONS 

		function T1 (f,c,d,e,w,k:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;

		function T2 (a,b,c:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;

		function Ch(c,d,e:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;

		function Maj(a,b,c:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;

		function SumA(a:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;

		function SumE(e:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;

		function Key(index: integer) 
		return std_logic_vector;


		function ROTR(WORD:std_logic_vector(word_size-1 downto 0);ROUNDS:integer) 
		return std_logic_vector;

		function SHR(WORD:std_logic_vector(word_size-1 downto 0);ROUNDS:integer) 
		return std_logic_vector;

		--- W FUNCTIONS 

		function W_HASHING_1(word:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;
		
		function W_HASHING_2(word:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector;


		function get_w_value (w_register: std_logic_vector (((rounds_number * word_size) - 1 )downto 0);
			w_index: integer) 
		return std_logic_vector;

		function generate_w_value(message_block:std_logic_vector(block_size-1 downto 0))
		return std_logic_vector;


		------ SHA384 HASHING FUNCTION 
	  	function SHA384_HASHING( message:std_logic_vector; 
		IV: std_logic_vector(hashed_size - 1 downto 0)) 
		return  std_logic_vector;

		------ HMACSHA384 HASHING FUNCTION	
		function HMACSHA384( IV : std_logic_vector (hashed_size-1 downto 0);-- salt
		KEY : std_logic_vector;  
		message :std_logic_vector) -- message size 
		return std_logic_vector;

		------ HMACSHA384 SUB FUNCTIONS 
		function opad_generate (block_size: integer) 
		return std_logic_vector;
		function ipad_generate (block_size: integer) 
		return std_logic_vector;
		
	end HMACSHA384_ISMAIL;
--------------------------------------------------------------------------------
--///////////////////// PACKAGE HEADER ENDS HERE /////////////////////////////--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--///////////////////// PACKAGE BODY STARTS HERE /////////////////////////////--
--------------------------------------------------------------------------------

	package body HMACSHA384_ISMAIL is --- START OF PACKAGE BODY 

	-------------------------
	---- MESSAGE PADDING ----
	-------------------------
		function message_padding (message: std_logic_vector) 
		return std_logic_vector is 
			variable mod_val: integer := (message'length) mod block_size;
			variable padding_length : integer := ((block_size-129)+(block_size - mod_val));
			variable padded_length : integer := (
					  message'length 
					+ (1 + padding_length) 
					+ length_bits
			);
			variable message_length: std_logic_vector(
				 (length_bits - 1) downto 0 
			) := (others=>'0');

			variable padded_message: std_logic_vector (
				 (padded_length - 1) downto 0
			) := (others => '0');
			variable padding: std_logic_vector (
				 (padding_length) downto 0
			) := (others => '0');
		begin

			message_length := std_logic_vector(to_unsigned(message'length,length_bits));
			padding := "1" & std_logic_vector(to_unsigned(0,padding_length));
			padded_message := message & padding & message_length;

			return padded_message;
		end message_padding;


	---------------------------------
	---- GET MESSAGE BLOCK COUNT ----
	---------------------------------
		function get_message_blocks_count(padded_message:std_logic_vector)
		return integer is 
		variable blocks_count : integer := (padded_message'length/block_size);
		begin
			
			return blocks_count;
		end get_message_blocks_count;
		
	---------------------------
	---- GET MESSAGE BLOCK ----
	---------------------------
		function get_message_block (padded_message:std_logic_vector; block_number: integer) 
		return std_logic_vector is 
			variable blocks_count : integer := get_message_blocks_count(padded_message);
		begin
			return padded_message(((blocks_count - block_number) * block_size) - 1 downto 
										 (((blocks_count - (block_number + 1)) * block_size ))) ;
		end get_message_block;

	--------------------
	---- FUNCTION F ----
	--------------------
		function F_FUNCTION  (H : std_logic_vector (hashed_size - 1 downto 0);
			message_block: std_logic_vector (block_size - 1 downto 0) )
			return std_logic_vector is 
				variable memory: std_logic_vector(5119 downto 0);
				variable a,b,c,d,e,f,w,k : std_logic_vector (word_size-1 downto 0);
				
			begin
				a := H(383 downto 320);
				b := H(319 downto 256);
				c := H(255 downto 192);
				d := H(191 downto 128);
				e := H(127 downto 64);
				f := H(63 downto 0);
				memory := generate_w_value(message_block);
				roundsloop : for i in 0 to (rounds_number-1) loop
					-- init values
					w := get_w_value(memory,i);
					k := Key(i);

					a := T1(f,c,d,e,w,k) + T2(a,b,c);
					b := a; 
					c := b; 
					d := c;
					e := d + T1(f,c,d,e,w,k);
					f := e;
				end loop ; -- roundsloop
				return (a & b & c & d & e & f); 
		end F_FUNCTION;

	---------------------------
	---- GENERATE T1 VALUE ----
	---------------------------
		function T1 (f,c,d,e,w,k:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector is 
		begin 	
			return (f + Ch(c,d,e) + SumE(e) + w + k);
		end T1;
	---------------------------
	---- GENERATE T2 VALUE ----
	---------------------------
		function T2 (a,b,c:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector is 
		begin 	
			return (SumA(a) + Maj(a,b,c));
		end T2;
	---------------------------
	---- GENERATE Ch VALUE ----
	---------------------------
		function Ch(c,d,e:std_logic_vector(word_size-1 downto 0)) 
			return std_logic_vector is 
			begin 	
				return ((c and d) xor ((not c) and e));
		end Ch;
	----------------------------
	---- GENERATE Maj VALUE ----
	----------------------------
		function Maj(a,b,c:std_logic_vector(word_size-1 downto 0)) 
			return std_logic_vector is 
			begin 	
				return ((a and b) xor (a and c) xor (b and c));
		end Maj;
	-----------------------------
	---- GENERATE SumA VALUE ----
	-----------------------------
		function SumA(a:std_logic_vector(word_size-1 downto 0)) 
			return std_logic_vector is 
			variable tmp: std_logic_vector (word_size-1 downto 0);
			begin 	
				identifier : for i in 0 to hashed_size loop
						tmp:= ROTR(a,28) xor ROTR(a,34) xor ROTR(a,39);
				end loop ; -- identifier
				return tmp;
		end SumA;

	-----------------------------
	---- GENERATE SumE VALUE ----
	-----------------------------
		function SumE(e:std_logic_vector(word_size-1 downto 0)) 
			return std_logic_vector is 
			variable tmp: std_logic_vector (word_size-1 downto 0);
			begin 	
				identifier : for i in 1 to hashed_size loop
						tmp:= ROTR(e,14) xor ROTR(e,18) xor ROTR(e,41);
				end loop ; -- identifier
				return tmp;
		end SumE;

	--------------------------
	---- GENERATE k VALUE ----
	--------------------------
		function Key(index: integer) 
		return std_logic_vector is 
		begin
			return std_logic_vector(to_unsigned(index,word_size));
		end Key;

	--------------------------
	---- GENERATE W VALUE ----
	--------------------------
		function generate_w_value(message_block:std_logic_vector(block_size-1 downto 0))
		return std_logic_vector is 
		variable generated_word : std_logic_vector(word_size-1 downto 0);
		variable WI1,WI2,WI3,WI4 : integer;
		variable w_leg : integer := (rounds_number * word_size) - 1;
	  	variable w_reg : std_logic_vector ( w_leg downto 0);
		begin
			w_reg( w_leg downto 4096) := message_block;
			wordGen : for t in 16 to (rounds_number - 1) loop

				WI1 := t - 16 ; WI2 := t - 15 ;
				WI3 := t - 7  ; WI4 := t -  2 ;
				w_reg ( (64*(80-(t))) - 1 downto (64*(80-(t+1))) )
				:=  w_reg ( (64*(80-(WI1))) - 1 downto (64*(80-(WI1+1))) ) 
					+
					W_HASHING_1(
						w_reg ( (64*(80-(WI2))) - 1 downto (64*(80-(WI2+1))) )
					) 
					+
					w_reg ( (64*(80-(WI3))) - 1 downto (64*(80-(WI3+1))) ) 
					+
					W_HASHING_2(
						w_reg ( (64*(80-(WI4))) - 1 downto (64*(80-(WI4+1))) )
					);

			end loop ; -- wordGen
			return w_reg;
		end  generate_w_value;
	---------------------
	---- GET W VALUE ----
	---------------------
		function get_w_value (w_register: std_logic_vector (((rounds_number * word_size) - 1 )downto 0);
							  w_index: integer) 
		return std_logic_vector is 
		begin 
			-- should not be more then 79 
			assert (w_index > (rounds_number - 1))
				report "the value should not be more than 79"
				severity warning;
			return w_register(((word_size * (rounds_number-w_index)) - 1) downto
					(word_size * (rounds_number-(w_index+1))));
		end get_w_value; 
	------------------------------
	---- W HASHING FUNCTIONS -----
	------------------------------
		-- FRIST W HASHING FUNCTION  
		function W_HASHING_1(word:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector is 
		variable hashedWord1 : std_logic_vector(word_size-1 downto 0);
		begin
			hash1looping : for i in 0 to hashed_size loop
				hashedWord1 := ROTR(word,1) xor ROTR(word,8) xor SHR(word,7); 
			end loop ; -- hash1looping
			return hashedWord1;
		end W_HASHING_1;

		-- SECOND W HASHING FUNCTION
		function W_HASHING_2(word:std_logic_vector(word_size-1 downto 0)) 
		return std_logic_vector is 
		variable hashedWord2 : std_logic_vector(word_size-1 downto 0);
		begin
			hash2looping : for i in 1 to hashed_size loop
				hashedWord2 := ROTR(word,19) xor ROTR(word,61) xor SHR(word,6); 
			end loop ; -- hash2looping
			return hashedWord2;
		end W_HASHING_2;

	-------------------------
	---- ROTATE Function ----
	-------------------------
		function ROTR(WORD:std_logic_vector(word_size-1 downto 0);ROUNDS:integer) 
		return std_logic_vector  is 
		variable ratatedWord: std_logic_vector(word_size-1 downto 0) := WORD; 
		begin
			ROTATELOOP : for i in 1 to ROUNDS loop
				ratatedWord := ratatedWord(0) & ratatedWord (word_size-1 downto 1);
			end loop ; -- ROTATELOOP

			return ratatedWord;
		end ROTR;


	-------------------------
	----  SHR Function   ----
	-------------------------
		function SHR(WORD:std_logic_vector(word_size-1 downto 0);ROUNDS:integer) 
		return std_logic_vector  is 
		variable shiftedWord: std_logic_vector(word_size-1 downto 0) := WORD; 
		begin
			SHIFTLOOP : for i in 1 to ROUNDS loop
				shiftedWord := "0" & shiftedWord (word_size-1 downto 1);
			end loop ; -- SHIFTLOOP

			return shiftedWord;
		end SHR;
		
	---------------------------------
	---- SHA384 HASHING Function ----
	---------------------------------
		function SHA384_HASHING( message:std_logic_vector; 
			IV: std_logic_vector(hashed_size - 1 downto 0)) 
		return  std_logic_vector is
			variable block_count : integer := 
				get_message_blocks_count(message_padding(message));
			variable mblock : std_logic_vector(block_size-1 downto 0);
			variable NHash : std_logic_vector(hashed_size-1 downto 0) := IV;
		begin
			identifier : for i in 0 to (block_count-1) loop
					mblock := get_message_block(message_padding(message),i);
					NHash := NHash + F_FUNCTION(NHash,mblock);
			end loop ; -- identifier
			return NHash;
		end SHA384_HASHING;
	------------------------
	---- HMAC FUNCTION -----
	------------------------
		function HMACSHA384( IV : std_logic_vector (hashed_size-1 downto 0);-- salt
							 KEY : std_logic_vector;  
							 message :std_logic_vector) -- message size 
		return std_logic_vector is 
			variable ipad : std_logic_vector (block_size - 1 downto 0) := ipad_generate(block_size);
			variable opad : std_logic_vector (block_size - 1 downto 0) := opad_generate(block_size);
			variable Si,So : std_logic_vector (block_size-1 downto 0); 
			variable kmessage1 : std_logic_vector((block_size + message'length)-1 downto 0);
			variable kmessage2 : std_logic_vector ((hashed_size + block_size)-1 downto 0);
			variable results1,results2: std_logic_vector((hashed_size -1 ) downto 0); 
		begin
				Si := KEY xor ipad;
				So := KEY xor opad; 
				kmessage1 := Si & message;
				results1 := SHA384_HASHING(kmessage1,IV);
				kmessage2 := So & results1; 
				results2 := SHA384_HASHING(kmessage2,IV);
				return results2; 
		end HMACSHA384; -- end of function
		
	-----------------------------
	---- GENERATE ipad VALUE ----
	-----------------------------
	function ipad_generate (block_size: integer) 
	return std_logic_vector is 
		variable repeat_times : integer := (block_size/8);
		variable final_ipad : std_logic_vector((8 * repeat_times)-1 downto 0);
		variable init_ipad : std_logic_vector(7 downto 0) := "00110110";
	begin
		repeatloop : for i in 0 to (repeat_times-1) loop
			final_ipad(((8 * (repeat_times-i))-1) downto ((8 * (repeat_times-(i+1)))))
			:= init_ipad;
		end loop ; -- repeatloop
		return final_ipad;
	end ipad_generate;
	-----------------------------
	---- GENERATE opad VALUE ----
	-----------------------------
	function opad_generate (block_size: integer) 
	return std_logic_vector is 
		variable repeat_times : integer := (block_size/8);
		variable final_opad : std_logic_vector((8 * repeat_times)-1 downto 0);
		variable init_opad : std_logic_vector(7 downto 0) := "01011100";
	begin
		repeatloop : for i in 0 to (repeat_times-1) loop
			final_opad(((8 * (repeat_times-i))-1) downto ((8 * (repeat_times-(i+1)))))
			:= init_opad;
		end loop ; -- repeatloop
		return final_opad;
	end opad_generate;
	end HMACSHA384_ISMAIL; --- END OF PACKAGE BODY 

--------------------------------------------------------------------------------
--///////////////////// PACKAGE BODY ENDS HERE ///////////////////////////////--
--------------------------------------------------------------------------------
