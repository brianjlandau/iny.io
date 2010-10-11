readFile := method(path,
   fileToRead := File clone openForReading(path)
   content := fileToRead readToEnd
   fileToRead close
   return content
)

# Pulled from http://iota.flowsnake.org/syntax-extensions.html
Object squareBrackets := method(
    r := List clone
    call message arguments foreach(arg,
        r push(call sender doMessage(arg)))
    r
)

# Pulled from http://github.com/tyler/iota/blob/master/vendor/iota/iota.io by Tyler McMullen
Object curlyBrackets := method( 
    map := Map clone
    call message arguments foreach(
      pair, map atPut(pair name, call sender doMessage(pair last))) )

# Based on code at http://iota.flowsnake.org/syntax-extensions.html
Map squareBrackets := method(key,
   self at(call evalArgAt(0))
)

# Pulled from http://iota.flowsnake.org/syntax-extensions.html
List squareBrackets := method(index,
   self at(call evalArgAt(0))
)

# Pulled from http://code.google.com/p/iopeg/wiki/IoNuggets
OperatorTable addOperator("||", 13)
Object || := method(
  if ( self,
    m := call message next ?next
    if ( m, call message setNext( m ) )    
    self
  ,
    call evalArgAt(0)
  )
)

# My own creation based on code at http://code.google.com/p/iopeg/wiki/IoNuggets
OperatorTable addAssignOperator( "||=", "createIfNonexistantOrUpdateIfNil" )
createIfNonexistantOrUpdateIfNil := method( seq, val,
   if (call sender hasSlot(seq)) then (
      currentValue := call sender doMessage( seq asMessage )  
      if (currentValue == nil) then (
         return call sender updateSlot( seq, val )
      ) else (
         return currentValue
      )
   ) else (
      return call sender setSlot(seq, val)
   )
)
