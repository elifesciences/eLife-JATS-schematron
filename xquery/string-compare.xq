let $string-1 := 'Urciuoli A, Zanolli C, Beaudet A, Dumoncel J, Santos F, Moyà-Solà S, Alba D M. 2020. The evolution of the vestibular apparatus in apes and humans. eLife 9:e51261. doi: 10.7554/eLife.51261'
let $string-2 := 'Urciuoli A, Zanolli C, Beaudet A, Dumoncel J, Santos F, Moyà-Solà S, Alba DM. 2020. The evolution of the vestibular apparatus in apes and humans. eLife 9:e51261. doi: 10.7554/eLife.51261'

for $token in tokenize($string-2,', |\. ')
return if (contains($string-1,$token)) then ()
else $token