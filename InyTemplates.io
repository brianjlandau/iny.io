InyTemplates := Object clone do (
   template_html := nil
   
   render := method(title, partial,
      template_html interpolate
   )
   
   with := method(path,
      self template_html := File @read(path)
		return self
   )
)
