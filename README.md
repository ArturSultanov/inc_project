# inc_project

University project of programming in VHDL.

Task:

Navrhněte obvod pro příjem datových slov po asynchronní sériové lince (UART_RX).
• Vycházejte ze základních informací o fungování a zpracování asynchronní sériové komunikace uvedených v následující kapitole.
• Uvažujte vstupní tok dat v pevném formátu: jeden START bit, 8 bitů dat, jeden STOP bit, zasílaných rychlostí 9600 baudů za sekundu. Přijímací obvod bude pracovat na 16x vyšší frekvenci (signál CLK) ve srovnání s přenosovou rychlostí jednotlivých datových bitů. Vašim úkolem bude snímat datové bity uprostřed přenášeného intervalu.
• Obvod UART_RX bude přijímat jednotlivé bity na vstupním datovém portu DIN, provede jejich de-serializaci a výsledné 8-bitové slovo zapíše na datový port DOUT. Platnost datového slova na portu DOUT potvrďte nastavením příznaku DOUT_VLD na úroveň logické 1 po dobu jednoho taktu hodinového signálu CLK.
