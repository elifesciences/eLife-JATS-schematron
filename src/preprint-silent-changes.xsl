<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns:e="https://elifesciences.org/namespace"
    exclude-result-prefixes="xs xsi e"
    version="3.0">
    
    <xsl:function name="e:stripDiacritics" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨıɉꝁłøɍŧɏƶ','bcdeghiijklortyz'),'[\p{M}’]',''),'æ','ae'),'ß','ss')"/>
    </xsl:function>

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" use-character-maps="char-map"/>
    
    <!-- Force hexadecimal entities for HTML named entities (required by Python XML parser) -->
    <xsl:character-map name="char-map">
        <xsl:output-character character="&#160;" string="&amp;#xA0;"/>
        <xsl:output-character character="&lt;" string="&amp;#x3c;"/>
        <xsl:output-character character="&gt;" string="&amp;#x3e;"/>
        <xsl:output-character character="≥" string="&amp;#x2265;"/>
        <xsl:output-character character="≤" string="&amp;#x2264;"/>
        <xsl:output-character character="α" string="&amp;#x3b1;"/>
        <xsl:output-character character="β" string="&amp;#x3b2;"/>
        <xsl:output-character character="γ" string="&amp;#x3b3;"/>
        <xsl:output-character character="δ" string="&amp;#x3b4;"/>
        <xsl:output-character character="ε" string="&amp;#x3b5;"/>
        <xsl:output-character character="ζ" string="&amp;#x3b6;"/>
        <xsl:output-character character="η" string="&amp;#x3b7;"/>
        <xsl:output-character character="θ" string="&amp;#x3b8;"/>
        <xsl:output-character character="ι" string="&amp;#x3b9;"/>
        <xsl:output-character character="κ" string="&amp;#x3ba;"/>
        <xsl:output-character character="λ" string="&amp;#x3bb;"/>
        <xsl:output-character character="μ" string="&amp;#x3bc;"/>
        <xsl:output-character character="ν" string="&amp;#x3bd;"/>
        <xsl:output-character character="ξ" string="&amp;#x3bE;"/>
        <xsl:output-character character="ο" string="&amp;#x3bf;"/>
        <xsl:output-character character="π" string="&amp;#x3c0;"/>
        <xsl:output-character character="ρ" string="&amp;#x3c1;"/>
        <xsl:output-character character="ς" string="&amp;#x3c2;"/>
        <xsl:output-character character="σ" string="&amp;#x3c3;"/>
        <xsl:output-character character="τ" string="&amp;#x3c4;"/>
        <xsl:output-character character="υ" string="&amp;#x3c5;"/>
        <xsl:output-character character="φ" string="&amp;#x3c6;"/>
        <xsl:output-character character="χ" string="&amp;#x3c7;"/>
        <xsl:output-character character="ψ" string="&amp;#x3c8;"/>
        <xsl:output-character character="ω" string="&amp;#x3c9;"/>
        <xsl:output-character character="Α" string="&amp;#x391;"/>
        <xsl:output-character character="Β" string="&amp;#x392;"/>
        <xsl:output-character character="Γ" string="&amp;#x393;"/>
        <xsl:output-character character="Δ" string="&amp;#x394;"/>
        <xsl:output-character character="Ε" string="&amp;#x395;"/>
        <xsl:output-character character="Ζ" string="&amp;#x396;"/>
        <xsl:output-character character="Η" string="&amp;#x397;"/>
        <xsl:output-character character="Θ" string="&amp;#x398;"/>
        <xsl:output-character character="Ι" string="&amp;#x399;"/>
        <xsl:output-character character="Κ" string="&amp;#x39a;"/>
        <xsl:output-character character="Λ" string="&amp;#x39b;"/>
        <xsl:output-character character="Μ" string="&amp;#x39c;"/>
        <xsl:output-character character="Ν" string="&amp;#x39d;"/>
        <xsl:output-character character="Ξ" string="&amp;#x39E;"/>
        <xsl:output-character character="Ο" string="&amp;#x39f;"/>
        <xsl:output-character character="Π" string="&amp;#x3a0;"/>
        <xsl:output-character character="Ρ" string="&amp;#x3a1;"/>
        <xsl:output-character character="Σ" string="&amp;#x3a3;"/>
        <xsl:output-character character="Τ" string="&amp;#x3a4;"/>
        <xsl:output-character character="Υ" string="&amp;#x3a5;"/>
        <xsl:output-character character="Φ" string="&amp;#x3a6;"/>
        <xsl:output-character character="Χ" string="&amp;#x3a7;"/>
        <xsl:output-character character="Ψ" string="&amp;#x3a8;"/>
        <xsl:output-character character="Ω" string="&amp;#x3a9;"/>
        
        <!-- Mathematical Script Capital Letters (U+1D49C-1D4B5) -->
        <xsl:output-character character="𝒜" string="&amp;#x1D49C;"/>
        <xsl:output-character character="𝒞" string="&amp;#x1D49E;"/>
        <xsl:output-character character="𝒟" string="&amp;#x1D49F;"/>
        <xsl:output-character character="𝒢" string="&amp;#x1D4A2;"/>
        <xsl:output-character character="𝒥" string="&amp;#x1D4A5;"/>
        <xsl:output-character character="𝒦" string="&amp;#x1D4A6;"/>
        <xsl:output-character character="𝒩" string="&amp;#x1D4A9;"/>
        <xsl:output-character character="𝒪" string="&amp;#x1D4AA;"/>
        <xsl:output-character character="𝒫" string="&amp;#x1D4AB;"/>
        <xsl:output-character character="𝒬" string="&amp;#x1D4AC;"/>
        <xsl:output-character character="𝒮" string="&amp;#x1D4AE;"/>
        <xsl:output-character character="𝒯" string="&amp;#x1D4AF;"/>
        <xsl:output-character character="𝒰" string="&amp;#x1D4B0;"/>
        <xsl:output-character character="𝒱" string="&amp;#x1D4B1;"/>
        <xsl:output-character character="𝒲" string="&amp;#x1D4B2;"/>
        <xsl:output-character character="𝒳" string="&amp;#x1D4B3;"/>
        <xsl:output-character character="𝒴" string="&amp;#x1D4B4;"/>
        <xsl:output-character character="𝒵" string="&amp;#x1D4B5;"/>
        
        <!-- Mathematical Script Small Letters (U+1D4B6-1D4CF) -->
        <xsl:output-character character="𝒶" string="&amp;#x1D4B6;"/>
        <xsl:output-character character="𝒷" string="&amp;#x1D4B7;"/>
        <xsl:output-character character="𝒸" string="&amp;#x1D4B8;"/>
        <xsl:output-character character="𝒹" string="&amp;#x1D4B9;"/>
        <xsl:output-character character="𝒺" string="&amp;#x1D4BA;"/>
        <xsl:output-character character="𝒻" string="&amp;#x1D4BB;"/>
        <xsl:output-character character="𝒼" string="&amp;#x1D4BC;"/>
        <xsl:output-character character="𝒽" string="&amp;#x1D4BD;"/>
        <xsl:output-character character="𝒾" string="&amp;#x1D4BE;"/>
        <xsl:output-character character="𝒿" string="&amp;#x1D4BF;"/>
        <xsl:output-character character="𝓀" string="&amp;#x1D4C0;"/>
        <xsl:output-character character="𝓁" string="&amp;#x1D4C1;"/>
        <xsl:output-character character="𝓂" string="&amp;#x1D4C2;"/>
        <xsl:output-character character="𝓃" string="&amp;#x1D4C3;"/>
        <xsl:output-character character="𝓄" string="&amp;#x1D4C4;"/>
        <xsl:output-character character="𝓅" string="&amp;#x1D4C5;"/>
        <xsl:output-character character="𝓆" string="&amp;#x1D4C6;"/>
        <xsl:output-character character="𝓇" string="&amp;#x1D4C7;"/>
        <xsl:output-character character="𝓈" string="&amp;#x1D4C8;"/>
        <xsl:output-character character="𝓉" string="&amp;#x1D4C9;"/>
        <xsl:output-character character="𝓊" string="&amp;#x1D4CA;"/>
        <xsl:output-character character="𝓋" string="&amp;#x1D4CB;"/>
        <xsl:output-character character="𝓌" string="&amp;#x1D4CC;"/>
        <xsl:output-character character="𝓍" string="&amp;#x1D4CD;"/>
        <xsl:output-character character="𝓎" string="&amp;#x1D4CE;"/>
        <xsl:output-character character="𝓏" string="&amp;#x1D4CF;"/>
        
        <!-- Mathematical Bold Script Capital Letters (U+1D4D0-1D4E9) -->
        <xsl:output-character character="𝓐" string="&amp;#x1D4D0;"/>
        <xsl:output-character character="𝓑" string="&amp;#x1D4D1;"/>
        <xsl:output-character character="𝓒" string="&amp;#x1D4D2;"/>
        <xsl:output-character character="𝓓" string="&amp;#x1D4D3;"/>
        <xsl:output-character character="𝓔" string="&amp;#x1D4D4;"/>
        <xsl:output-character character="𝓕" string="&amp;#x1D4D5;"/>
        <xsl:output-character character="𝓖" string="&amp;#x1D4D6;"/>
        <xsl:output-character character="𝓗" string="&amp;#x1D4D7;"/>
        <xsl:output-character character="𝓘" string="&amp;#x1D4D8;"/>
        <xsl:output-character character="𝓙" string="&amp;#x1D4D9;"/>
        <xsl:output-character character="𝓚" string="&amp;#x1D4DA;"/>
        <xsl:output-character character="𝓛" string="&amp;#x1D4DB;"/>
        <xsl:output-character character="𝓜" string="&amp;#x1D4DC;"/>
        <xsl:output-character character="𝓝" string="&amp;#x1D4DD;"/>
        <xsl:output-character character="𝓞" string="&amp;#x1D4DE;"/>
        <xsl:output-character character="𝓟" string="&amp;#x1D4DF;"/>
        <xsl:output-character character="𝓠" string="&amp;#x1D4E0;"/>
        <xsl:output-character character="𝓡" string="&amp;#x1D4E1;"/>
        <xsl:output-character character="𝓢" string="&amp;#x1D4E2;"/>
        <xsl:output-character character="𝓣" string="&amp;#x1D4E3;"/>
        <xsl:output-character character="𝓤" string="&amp;#x1D4E4;"/>
        <xsl:output-character character="𝓥" string="&amp;#x1D4E5;"/>
        <xsl:output-character character="𝓦" string="&amp;#x1D4E6;"/>
        <xsl:output-character character="𝓧" string="&amp;#x1D4E7;"/>
        <xsl:output-character character="𝓨" string="&amp;#x1D4E8;"/>
        <xsl:output-character character="𝓩" string="&amp;#x1D4E9;"/>
        
        <!-- Mathematical Bold Script Small Letters (U+1D4EA-1D503) -->
        <xsl:output-character character="𝓪" string="&amp;#x1D4EA;"/>
        <xsl:output-character character="𝓫" string="&amp;#x1D4EB;"/>
        <xsl:output-character character="𝓬" string="&amp;#x1D4EC;"/>
        <xsl:output-character character="𝓭" string="&amp;#x1D4ED;"/>
        <xsl:output-character character="𝓮" string="&amp;#x1D4EE;"/>
        <xsl:output-character character="𝓯" string="&amp;#x1D4EF;"/>
        <xsl:output-character character="𝓰" string="&amp;#x1D4F0;"/>
        <xsl:output-character character="𝓱" string="&amp;#x1D4F1;"/>
        <xsl:output-character character="𝓲" string="&amp;#x1D4F2;"/>
        <xsl:output-character character="𝓳" string="&amp;#x1D4F3;"/>
        <xsl:output-character character="𝓴" string="&amp;#x1D4F4;"/>
        <xsl:output-character character="𝓵" string="&amp;#x1D4F5;"/>
        <xsl:output-character character="𝓶" string="&amp;#x1D4F6;"/>
        <xsl:output-character character="𝓷" string="&amp;#x1D4F7;"/>
        <xsl:output-character character="𝓸" string="&amp;#x1D4F8;"/>
        <xsl:output-character character="𝓹" string="&amp;#x1D4F9;"/>
        <xsl:output-character character="𝓺" string="&amp;#x1D4FA;"/>
        <xsl:output-character character="𝓻" string="&amp;#x1D4FB;"/>
        <xsl:output-character character="𝓼" string="&amp;#x1D4FC;"/>
        <xsl:output-character character="𝓽" string="&amp;#x1D4FD;"/>
        <xsl:output-character character="𝓾" string="&amp;#x1D4FE;"/>
        <xsl:output-character character="𝓿" string="&amp;#x1D4FF;"/>
        <xsl:output-character character="𝔀" string="&amp;#x1D500;"/>
        <xsl:output-character character="𝔁" string="&amp;#x1D501;"/>
        <xsl:output-character character="𝔂" string="&amp;#x1D502;"/>
        <xsl:output-character character="𝔃" string="&amp;#x1D503;"/>
        
        <!-- Mathematical Bold Capital Letters (U+1D400–U+1D419) -->
        <xsl:output-character character="𝐀" string="&amp;#x1D400;"/>
        <xsl:output-character character="𝐁" string="&amp;#x1D401;"/>
        <xsl:output-character character="𝐂" string="&amp;#x1D402;"/>
        <xsl:output-character character="𝐃" string="&amp;#x1D403;"/>
        <xsl:output-character character="𝐄" string="&amp;#x1D404;"/>
        <xsl:output-character character="𝐅" string="&amp;#x1D405;"/>
        <xsl:output-character character="𝐆" string="&amp;#x1D406;"/>
        <xsl:output-character character="𝐇" string="&amp;#x1D407;"/>
        <xsl:output-character character="𝐈" string="&amp;#x1D408;"/>
        <xsl:output-character character="𝐉" string="&amp;#x1D409;"/>
        <xsl:output-character character="𝐊" string="&amp;#x1D40A;"/>
        <xsl:output-character character="𝐋" string="&amp;#x1D40B;"/>
        <xsl:output-character character="𝐌" string="&amp;#x1D40C;"/>
        <xsl:output-character character="𝐍" string="&amp;#x1D40D;"/>
        <xsl:output-character character="𝐎" string="&amp;#x1D40E;"/>
        <xsl:output-character character="𝐏" string="&amp;#x1D40F;"/>
        <xsl:output-character character="𝐐" string="&amp;#x1D410;"/>
        <xsl:output-character character="𝐑" string="&amp;#x1D411;"/>
        <xsl:output-character character="𝐒" string="&amp;#x1D412;"/>
        <xsl:output-character character="𝐓" string="&amp;#x1D413;"/>
        <xsl:output-character character="𝐔" string="&amp;#x1D414;"/>
        <xsl:output-character character="𝐕" string="&amp;#x1D415;"/>
        <xsl:output-character character="𝐖" string="&amp;#x1D416;"/>
        <xsl:output-character character="𝐗" string="&amp;#x1D417;"/>
        <xsl:output-character character="𝐘" string="&amp;#x1D418;"/>
        <xsl:output-character character="𝐙" string="&amp;#x1D419;"/>
        
        <!-- Mathematical Bold Small Letters (U+1D41A–U+1D433) -->
        <xsl:output-character character="𝐚" string="&amp;#x1D41A;"/>
        <xsl:output-character character="𝐛" string="&amp;#x1D41B;"/>
        <xsl:output-character character="𝐜" string="&amp;#x1D41C;"/>
        <xsl:output-character character="𝐝" string="&amp;#x1D41D;"/>
        <xsl:output-character character="𝐞" string="&amp;#x1D41E;"/>
        <xsl:output-character character="𝐟" string="&amp;#x1D41F;"/>
        <xsl:output-character character="𝐠" string="&amp;#x1D420;"/>
        <xsl:output-character character="𝐡" string="&amp;#x1D421;"/>
        <xsl:output-character character="𝐢" string="&amp;#x1D422;"/>
        <xsl:output-character character="𝐣" string="&amp;#x1D423;"/>
        <xsl:output-character character="𝐤" string="&amp;#x1D424;"/>
        <xsl:output-character character="𝐥" string="&amp;#x1D425;"/>
        <xsl:output-character character="𝐦" string="&amp;#x1D426;"/>
        <xsl:output-character character="𝐧" string="&amp;#x1D427;"/>
        <xsl:output-character character="𝐨" string="&amp;#x1D428;"/>
        <xsl:output-character character="𝐩" string="&amp;#x1D429;"/>
        <xsl:output-character character="𝐪" string="&amp;#x1D42A;"/>
        <xsl:output-character character="𝐫" string="&amp;#x1D42B;"/>
        <xsl:output-character character="𝐬" string="&amp;#x1D42C;"/>
        <xsl:output-character character="𝐭" string="&amp;#x1D42D;"/>
        <xsl:output-character character="𝐮" string="&amp;#x1D42E;"/>
        <xsl:output-character character="𝐯" string="&amp;#x1D42F;"/>
        <xsl:output-character character="𝐰" string="&amp;#x1D430;"/>
        <xsl:output-character character="𝐱" string="&amp;#x1D431;"/>
        <xsl:output-character character="𝐲" string="&amp;#x1D432;"/>
        <xsl:output-character character="𝐳" string="&amp;#x1D433;"/>
        
        <!-- Mathematical Italic Capital Letters (U+1D434–U+1D44D) -->
        <xsl:output-character character="𝐴" string="&amp;#x1D434;"/>
        <xsl:output-character character="𝐵" string="&amp;#x1D435;"/>
        <xsl:output-character character="𝐶" string="&amp;#x1D436;"/>
        <xsl:output-character character="𝐷" string="&amp;#x1D437;"/>
        <xsl:output-character character="𝐸" string="&amp;#x1D438;"/>
        <xsl:output-character character="𝐹" string="&amp;#x1D439;"/>
        <xsl:output-character character="𝐺" string="&amp;#x1D43A;"/>
        <xsl:output-character character="𝐻" string="&amp;#x1D43B;"/>
        <xsl:output-character character="𝐼" string="&amp;#x1D43C;"/>
        <xsl:output-character character="𝐽" string="&amp;#x1D43D;"/>
        <xsl:output-character character="𝐾" string="&amp;#x1D43E;"/>
        <xsl:output-character character="𝐿" string="&amp;#x1D43F;"/>
        <xsl:output-character character="𝑀" string="&amp;#x1D440;"/>
        <xsl:output-character character="𝑁" string="&amp;#x1D441;"/>
        <xsl:output-character character="𝑂" string="&amp;#x1D442;"/>
        <xsl:output-character character="𝑃" string="&amp;#x1D443;"/>
        <xsl:output-character character="𝑄" string="&amp;#x1D444;"/>
        <xsl:output-character character="𝑅" string="&amp;#x1D445;"/>
        <xsl:output-character character="𝑆" string="&amp;#x1D446;"/>
        <xsl:output-character character="𝑇" string="&amp;#x1D447;"/>
        <xsl:output-character character="𝑈" string="&amp;#x1D448;"/>
        <xsl:output-character character="𝑉" string="&amp;#x1D449;"/>
        <xsl:output-character character="𝑊" string="&amp;#x1D44A;"/>
        <xsl:output-character character="𝑋" string="&amp;#x1D44B;"/>
        <xsl:output-character character="𝑌" string="&amp;#x1D44C;"/>
        <xsl:output-character character="𝑍" string="&amp;#x1D44D;"/>
        
        <!-- Mathematical Italic Small Letters (U+1D44E–U+1D467) -->
        <xsl:output-character character="𝑎" string="&amp;#x1D44E;"/>
        <xsl:output-character character="𝑏" string="&amp;#x1D44F;"/>
        <xsl:output-character character="𝑐" string="&amp;#x1D450;"/>
        <xsl:output-character character="𝑑" string="&amp;#x1D451;"/>
        <xsl:output-character character="𝑒" string="&amp;#x1D452;"/>
        <xsl:output-character character="𝑓" string="&amp;#x1D453;"/>
        <xsl:output-character character="𝑔" string="&amp;#x1D454;"/>
        <xsl:output-character character="ℎ" string="&amp;#x1D455;"/>
        <xsl:output-character character="𝑖" string="&amp;#x1D456;"/>
        <xsl:output-character character="𝑗" string="&amp;#x1D457;"/>
        <xsl:output-character character="𝑘" string="&amp;#x1D458;"/>
        <xsl:output-character character="𝑙" string="&amp;#x1D459;"/>
        <xsl:output-character character="𝑚" string="&amp;#x1D45A;"/>
        <xsl:output-character character="𝑛" string="&amp;#x1D45B;"/>
        <xsl:output-character character="𝑜" string="&amp;#x1D45C;"/>
        <xsl:output-character character="𝑝" string="&amp;#x1D45D;"/>
        <xsl:output-character character="𝑞" string="&amp;#x1D45E;"/>
        <xsl:output-character character="𝑟" string="&amp;#x1D45F;"/>
        <xsl:output-character character="𝑠" string="&amp;#x1D460;"/>
        <xsl:output-character character="𝑡" string="&amp;#x1D461;"/>
        <xsl:output-character character="𝑢" string="&amp;#x1D462;"/>
        <xsl:output-character character="𝑣" string="&amp;#x1D463;"/>
        <xsl:output-character character="𝑤" string="&amp;#x1D464;"/>
        <xsl:output-character character="𝑥" string="&amp;#x1D465;"/>
        <xsl:output-character character="𝑦" string="&amp;#x1D466;"/>
        <xsl:output-character character="𝑧" string="&amp;#x1D467;"/>
        
        <!-- Blackboard Bold (Double-Struck) Letters -->
        <xsl:output-character character="ℂ" string="&amp;#x2102;"/>
        <xsl:output-character character="ℍ" string="&amp;#x210D;"/>
        <xsl:output-character character="ℕ" string="&amp;#x2115;"/>
        <xsl:output-character character="ℙ" string="&amp;#x2119;"/>
        <xsl:output-character character="ℚ" string="&amp;#x211A;"/>
        <xsl:output-character character="ℝ" string="&amp;#x211D;"/>
        <xsl:output-character character="ℤ" string="&amp;#x2124;"/>
    </xsl:character-map>

     <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Update dtd-version attribute to 1.3
         remove specific-use attribute
         change article-type to conform with VORs
         add namespace definitions to root element if missing -->
    <xsl:template xml:id="article-changes" match="article">
        <xsl:copy>
            <xsl:choose>
                <!-- to account for review articles under the new model -->
                <xsl:when test="@article-type='review-article'">
                    <xsl:apply-templates select="@article-type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="article-type">research-article</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="dtd-version">1.3</xsl:attribute>
            <xsl:apply-templates select="@*[not(name()=('dtd-version','specific-use','article-type'))]"/>
            <!-- If ali, mml and xlink namespaces are missing on root -->
            <xsl:if test="empty(namespace::mml)">
                <xsl:namespace name="mml">http://www.w3.org/1998/Math/MathML</xsl:namespace>
            </xsl:if>
            <xsl:if test="empty(namespace::ali)">
                <xsl:namespace name="ali">http://www.niso.org/schemas/ali/1.0/</xsl:namespace>
            </xsl:if>
            <xsl:if test="empty(namespace::xlink)">
                <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
            </xsl:if>
            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Replace preprint server information with eLife -->
    <xsl:template xml:id="journal-meta" match="journal-meta">
        <journal-meta>
        <xsl:text>&#xa;</xsl:text>
            <journal-id journal-id-type="nlm-ta">elife</journal-id>
            <xsl:text>&#xa;</xsl:text>
            <journal-id journal-id-type="publisher-id">eLife</journal-id>
            <xsl:text>&#xa;</xsl:text>
            <journal-title-group>
            <xsl:text>&#xa;</xsl:text>
                <journal-title>eLife</journal-title>
            <xsl:text>&#xa;</xsl:text>
            </journal-title-group>
            <xsl:text>&#xa;</xsl:text>
            <issn publication-format="electronic" pub-type="epub">2050-084X</issn>
            <xsl:text>&#xa;</xsl:text>
            <publisher>
            <xsl:text>&#xa;</xsl:text>
                <publisher-name>eLife Sciences Publications, Ltd</publisher-name>
            <xsl:text>&#xa;</xsl:text>
            </publisher>
            <xsl:text>&#xa;</xsl:text>
        </journal-meta>
    </xsl:template>
    
    <!-- Changes to article-meta: 
            - Introduce flag to distinguish between reviewed-preprint and VOR XML
            - Ensure correct ordering of elements -->
    <xsl:template xml:id="article-meta-changes" match="article-meta">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="article-id|article-id/following-sibling::text()[1]"/>
            <!-- multiple article versions need to be wrapped in <article-version-alternatives> -->
            <xsl:choose>
                <xsl:when test="./article-version-alternatives">
                    <xsl:element name="article-version-alternatives">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:element name="article-version">
                            <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                            <xsl:text>reviewed preprint</xsl:text>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:for-each select="./article-version-alternatives/article-version[not(@article-version-type='publication-state')]">
                            <xsl:copy>
                                <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                            </xsl:copy>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:when>
                <xsl:when test="./article-version">
                    <xsl:element name="article-version-alternatives">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:element name="article-version">
                            <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                            <xsl:text>reviewed preprint</xsl:text>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:element name="article-version">
                            <xsl:attribute name="article-version-type">preprint-version</xsl:attribute>
                            <xsl:value-of select="./article-version"/>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="article-version">
                        <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                        <xsl:text>reviewed preprint</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="article-categories|article-categories/following-sibling::text()[1]"/>
            <xsl:apply-templates select="title-group|title-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('contrib-group','aff','aff-alternatives','x')]|*[name()=('contrib-group','aff','aff-alternatives','x')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="author-notes|author-notes/following-sibling::text()[1]"/>
            <xsl:apply-templates select="pub-date|pub-date/following-sibling::text()[1]"/>
            <xsl:apply-templates select="pub-date-not-available|pub-date-not-available/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume|volume/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume-id|volume-id/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume-series|volume-series/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue|issue/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-id|issue-id/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-title|issue-title/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-title-group|issue-title-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-sponsor|issue-sponsor/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume-issue-group|volume-issue-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="isbn|isbn/following-sibling::text()[1]"/>
            <xsl:apply-templates select="supplement|supplement/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('fpage','lpage','page-range','elocation-id')] | *[name()=('fpage','lpage','page-range','elocation-id')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('email','ext-link','uri','product','supplementary-material')] | *[name()=('email','ext-link','uri','product','supplementary-material')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="history|history/following-sibling::text()[1]"/>
            <xsl:apply-templates select="pub-history|pub-history/following-sibling::text()[1]"/>
            <xsl:apply-templates select="permissions|permissions/following-sibling::text()[1]"/>
            <xsl:apply-templates select="self-uri|self-uri/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('related-article','related-object')] | *[name()=('related-article','related-object')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="abstract|abstract/following-sibling::text()[1]"/>
            <xsl:apply-templates select="trans-abstract|trans-abstract/following-sibling::text()[1]"/>
            <xsl:apply-templates select="kwd-group|kwd-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="funding-group|funding-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="support-group|support-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="conference|conference/following-sibling::text()[1]"/>
            <xsl:apply-templates select="custom-meta-group|custom-meta-group/following-sibling::text()[1]"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Change capitalisation of eLife [aA]ssessment -->
    <xsl:template xml:id="assessment-capitalisation" match="sub-article/front-stub//article-title">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="replace(.,'[\s:\n\.]','')='eLifeassessment'">
                    <xsl:text>eLife Assessment</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- Add editor as author of eLife Assessment -->
    <xsl:template xml:id="assessment-author" match="article[//article-meta/contrib-group[@content-type='section']/contrib[@contrib-type='editor']]/sub-article[@article-type='editor-report']/front-stub">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[name()!='kwd-group']|text()[not(preceding-sibling::kwd-group)]"/>
            <xsl:variable name="editor" select="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[@contrib-type='editor']"/>
            <xsl:element name="contrib-group">
                <xsl:text>&#xa;</xsl:text>
                <xsl:element name="contrib">
                    <xsl:attribute name="contrib-type">author</xsl:attribute>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:copy-of select="$editor/*:name"/>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:element name="role">
                        <xsl:attribute name="specific-use">editor</xsl:attribute>
                        <xsl:text>Reviewing Editor</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:if test="$editor/contrib-id">
                        <xsl:copy-of select="$editor/contrib-id"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$editor/aff">
                        <xsl:element name="aff">
                            <xsl:text>&#xa;</xsl:text>
                            <xsl:if test="$editor/aff/*[name()=('institution','institution-wrap')]">
                                <xsl:copy-of select="$editor/aff/*[name()=('institution','institution-wrap')]"/>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                            <xsl:if test="$editor/aff/addr-line">
                                <xsl:element name="city">
                                    <xsl:value-of select="$editor/aff/addr-line"/>
                                </xsl:element>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                            <xsl:if test="$editor/aff/country">
                                <xsl:copy-of select="$editor/aff/country"/>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                </xsl:element>
                <xsl:text>&#xa;</xsl:text>
            </xsl:element>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="kwd-group|text()[preceding-sibling::kwd-group]"/>
        </xsl:copy>
    </xsl:template>

    <!-- Convert ext-link elements that contain dois in refs to correct semantic capture: pub-id -->
    <xsl:template xml:id="ref-doi-fix" match="ref//ext-link[@ext-link-type='uri'][matches(lower-case(@xlink:href),'^https?://(dx\.)?doi\.org/')]">
        <xsl:element name="pub-id">
            <xsl:attribute name="pub-id-type">doi</xsl:attribute>
            <xsl:value-of select="substring(@xlink:href, (string-length(@xlink:href) - string-length(substring-after(lower-case(@xlink:href),'doi.org/')) + 1))"/>
        </xsl:element>
    </xsl:template>

    <!-- Convert uri elements to ext-link -->
    <xsl:template xml:id="uri-to-ext-link" match="uri">
        <xsl:choose>
            <xsl:when test="ancestor::mixed-citation and matches(lower-case(.),'^https?://(dx\.)?doi\.org/')">
                <xsl:element name="pub-id">
                    <xsl:attribute name="pub-id-type">doi</xsl:attribute>
                    <xsl:value-of select="substring(., (string-length(.) - string-length(substring-after(lower-case(.),'doi.org/')) + 1))"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="./@xlink:href">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type">uri</xsl:attribute>
                    <xsl:attribute name="xlink:href"><xsl:value-of select="./@xlink:href"/></xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type">uri</xsl:attribute>
                    <xsl:attribute name="xlink:href"><xsl:value-of select="."/></xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Convert addr-line (with named-content) to city -->
    <xsl:template xml:id="addr-line-to-city" match="addr-line[named-content[@content-type='city']]">
        <xsl:element name="city">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <!-- introduce mimetype and mime-subtype when missing -->
    <xsl:template xml:id="graphics" match="graphic|inline-graphic">
        <xsl:choose>
            <xsl:when test="./@mime-subtype">
                <xsl:copy>
                    <xsl:apply-templates select="@*[name()!='mimetype']"/>
                    <xsl:attribute name="mimetype">image</xsl:attribute>
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:when>
            <!-- No link to file, cannot determine mime-subtype -->
            <xsl:when test="not(@xlink:href)">
                <xsl:copy>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="file" select="tokenize(lower-case(@xlink:href),'\.')[last()]"/>
                <xsl:variable name="mime-subtype">
                    <xsl:choose>
                        <xsl:when test="$file=('tif','tiff')">tiff</xsl:when>
                        <xsl:when test="$file=('jpeg','jpg')">jpeg</xsl:when>
                        <xsl:when test="$file='gif'">gif</xsl:when>
                        <xsl:when test="$file='png'">png</xsl:when>
                        <xsl:otherwise>unknown</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <!-- no @mime-subtype -->
                    <xsl:when test="$mime-subtype!='unknown'">
                        <xsl:copy>
                            <xsl:apply-templates select="@*[name()!='mimetype']"/>
                            <xsl:attribute name="mimetype">image</xsl:attribute>
                            <xsl:attribute name="mime-subtype"><xsl:value-of select="$mime-subtype"/></xsl:attribute>
                            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- It is not a known/supported image type -->
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*[name()!='mimetype']"/>
                            <xsl:attribute name="mimetype">image</xsl:attribute>
                            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Introduce id for top-level sections (with titles) that don't have them, so they appear in the TOC on EPP -->
    <xsl:template match="(body|back)/sec[title and not(@id)]">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Introduce id for supplementary-material -->
    <xsl:template match="supplementary-material[not(@id)]">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Strip or convert HTML <i> tags -->
    <xsl:template xml:id="strip-i-tags" match="i">
        <xsl:choose>
            <xsl:when test="ancestor::italic">
                <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="italic">
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Strip or convert HTML <blockquote> tags -->
    <xsl:template xml:id="strip-blockquote-tags" match="blockquote">
        <xsl:choose>
            <xsl:when test="ancestor::disp-quote">
                <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="disp-quote">
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Standardise certain country names -->
    <xsl:template xml:id="country-standardisation" match="aff//country">
        <xsl:variable name="lc" select="e:stripDiacritics(replace(lower-case(.),'[\(\)]',''))"/>
        <xsl:variable name="countries" select="'countries.xml'"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="matches($lc,'^(the )?(u\.?s\.?a?\.?|unite[ds] states( of america)?)\.?$')">
                    <xsl:attribute name="country">US</xsl:attribute>
                    <xsl:text>United States</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?(u\.?k\.?|unite[ds] kingdom|england|wales|scotland)\.?$')">
                    <xsl:attribute name="country">GB</xsl:attribute>
                    <xsl:text>United Kingdom</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?([rp]\.?\s?[pr]\.?|(people’?s )?republic( of)?)?\s?china\.?$')">
                    <xsl:attribute name="country">CN</xsl:attribute>
                    <xsl:text>China</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?(holland|netherlands)\.?$')">
                    <xsl:attribute name="country">NL</xsl:attribute>
                    <xsl:text>Netherlands</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?(republic of|south)?\s?korea\.?$')">
                    <xsl:attribute name="country">KR</xsl:attribute>
                    <xsl:text>Republic of Korea</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?(turkiye|turkey)\.?$')">
                    <xsl:attribute name="country">TR</xsl:attribute>
                    <xsl:text>Turkiye</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?russia\.?$')">
                    <xsl:attribute name="country">RU</xsl:attribute>
                    <xsl:text>Russian Federation</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?tanzania\.?$')">
                    <xsl:attribute name="country">TZ</xsl:attribute>
                    <xsl:text>United Republic of Tanzania</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?vietnam\.?$')">
                    <xsl:attribute name="country">VN</xsl:attribute>
                    <xsl:text>Viet Nam</xsl:text>
                </xsl:when>
                <xsl:when test="document($countries)//*:country[lower-case(.)=$lc]">
                    <xsl:attribute name="country">
                        <xsl:value-of select="document($countries)//*:country[lower-case(.)=$lc]/@country"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="document($countries)//*:country[lower-case(.)=$lc]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>