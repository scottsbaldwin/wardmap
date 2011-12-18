
category = %w{A L P N U S}
1.upto(102) do |x|
	print x, ",123 W,Surname,", category[x%6],"\n"
end
