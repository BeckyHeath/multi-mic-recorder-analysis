function data = metaDesc(val1,val2, val3, val4,val5)

    outStr = "";

   if val3 > 0 
       outStr = val3 + " dead strings";
       if val4 + val5 > 0 
           outStr = outStr + " and"; 
       end 
   end 

   if val4 > 0 
       outStr = val4 + " part dead strings";
       if val5 > 0 
           outStr = outStr + " and"; 
       end 
   end 
      
   if val5 > 0 
       outStr = val5 + " anomolous channels";
   end 

   if outStr == ""
       outStr = "ok";
   end 
            
   outLine = outStr;

   data = outLine;
end
