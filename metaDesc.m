function data = metaDesc(val1,val2, val3, val4,val5)

    outStr = "";

   if val3 > 0 
       outStr = outStr + " " + val3 + " dead";
       if val4 + val5 > 0 
           outStr = outStr + " +"; 
       end 
   end 

   if val4 > 0 
       outStr = outStr + " " +  val4 + " part-dead";
       if val5 > 0 
           outStr = outStr + " +"; 
       end 
   end 
      
   if val5 > 0 
       outStr = outStr + " " + val5 + " irregular";
   end 

   if outStr == ""
       outStr = "ok";
   end 
            
   outLine = outStr;

   data = outLine;
end
