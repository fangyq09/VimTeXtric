"=============================================================================
" Vim color scheme file
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
""https://www.w3schools.com/colors/color_tryit.asp?hex=FFF0BA
""http://www.w3school.com.cn/tags/html_ref_colornames.asp
""https://www.ditig.com/256-colors-cheat-sheet
""#FFF0BA,#E4DABE,#E7E4BD
"=============================================================================

function! s:syntax_query() abort
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name"). ' -> ' . synIDattr(synIDtrans(id), 'name')
  endfor
endfunction
command! SyntaxQuery call s:syntax_query()

set bg=light
hi clear
if exists("syntax_on")
	syntax reset
endif

let colors_name = "parbermad"

"hi Normal		guifg=#000000 guibg=#E4DABE		
hi Normal		guifg=#000000 guibg=#FFF0BA	
hi ErrorMsg		guifg=red guibg=#ffffff	
hi Error		guifg=red guibg=#ffffff		
hi Visual		guifg=#8080ff guibg=#FFFFFF	gui=reverse	
hi VisualNOS	guifg=#8080ff guibg=#FFFFFF		gui=reverse,underline
hi Todo			guifg=blue guibg=darkgoldenrod	
hi Search		guifg=#000000 guibg=#FFD700			
hi IncSearch	guifg=#b0ffff guibg=#2050d0	
hi MatchParen   guifg=Black guibg=CadetBlue 	
hi SpecialKey		guifg=darkgreen			
hi Directory		guifg=deeppink			
hi Title				guifg=magenta gui=bold 
hi WarningMsg		guifg=darkred			
hi WildMenu			guifg=yellow guibg=black 
hi ModeMsg			guifg=#22cce2		
hi MoreMsg			guifg=darkgreen	
hi Question			guifg=green gui=none  
hi NonText			guifg=#0030ff		
hi StatusLine 	guifg=#000000	guibg=#FFD700	gui=none    
hi StatusLineNC		guifg=black guibg=Grey42 gui=none		
hi VertSplit		guifg=black guibg=Grey42 gui=none	 
hi Folded  	guifg=black	guibg=darksalmon	
hi FoldColumn		guifg=Grey guibg=#000040			 
hi LineNr			guifg=red			 
hi DiffAdd			guibg=#ADEBB3 
hi DiffChange		guibg=#c98ec4  
hi DiffDelete		gui=bold guifg=Blue guibg=#85d2c3 
hi DiffText			gui=bold guibg=#be84b9  
hi Cursor      guifg=#ffffff guibg=#6600CC
hi lCursor		 guifg=#ffffff guibg=#000000 
hi CursorLine  guibg=peachpuff ctermbg=223 
hi CursorIM    guifg=#000000	guibg=#8A4C98 
hi Comment	guifg=black guibg=#F5DEB3 	
hi String		guifg=DarkGreen gui=bold 
hi Special	guifg=BlueViolet gui=bold 
hi Identifier	guifg=brown gui=none    
hi Statement	guifg=#5555ff gui=bold  
hi PreProc		guifg=green3 gui=bold   
hi PreCondit	guifg=green4 gui=bold   
hi type				guifg=magenta gui=bold  
hi Label      guifg=Olive gui=bold    
hi Operator   guifg=brown gui=bold    
hi Number     guifg=red gui=bold      
hi Constant		guifg=#ff88d3 gui=bold  
hi Function   guifg=DarkOliveGreen  gui=bold  
hi IO					guifg=red gui=bold 
hi Communicator		guibg=yellow guifg=black gui=none 
hi UnitHeader			guibg=lightblue guifg=black gui=bold  
hi Macro        guifg=#1A5FB4 
hi Keyword      	guifg=orangered 
hi Underlined	gui=underline 
hi Ignore	guifg=#FFF0BA 
hi colorcolumn 	 guibg=#999933 
hi Conceal  guifg=green4 guibg=peachpuff gui=bold
hi Delimiter		guifg=DarkCyan gui=bold 
hi SpellBad	gui=undercurl,bold,italic guifg=Purple4  

hi texSectionMarker		guifg=darkgoldenrod	    gui=bold   
hi texSection		      guifg=Olive	          gui=bold,underline 
hi texSectionName			guifg=Black             gui=bold 
hi texInputFile				guifg=ForestGreen       
hi texCmdArgs			    guifg=SkyBlue           gui=bold 
hi texInputFileOpt			guifg=#999933           
hi texType				      guifg=DarkSlateGray     
hi texTypeStyle		    guifg=DarkGreen         
hi texMath				      guifg=Red4              gui=bold 
hi texStatement 				guifg=Blue              
hi texString				    guifg=Blue4            
hi texSpecialChar			guifg=DodgerBlue        
hi texRefZone					guifg=DeepPink2		      gui=bold 
hi texCite							guifg=DeepPink4        
hi texGreek				    guifg=Green4            gui=bold	
hi texDef					    guifg=DodgerBlue        
hi texMathSymbol 	    guifg=NavyBlue          
"hi texMathDelim		    guifg=MidnightBlue     
"hi texMathOper			    guifg=Purple           
hi texRefOption				guifg=HotPink4          
hi texMathMatcher  	  guifg=DarkOrange3       


