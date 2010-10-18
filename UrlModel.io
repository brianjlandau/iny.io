doFile("Iodis.io")

InyioRedisConnection := Object clone do (
  getConnection := method(
      Iodis clone connect
  )
)

UrlModel := Object clone do (
	characters := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
	tokenLength := 5
	
	find := method(token,
		return InyioRedisConnection getConnection get(token)
	)
	
	create := method(url,
	  redisConnection := InyioRedisConnection getConnection
		if (redisConnection exists(url)) then (
			return redisConnection get(url)
		) else (
			token := generateToken
			while (redisConnection exists(token),
				token = generateToken
			)
			redisConnection @set(token, url)
			redisConnection @set(url, token)
			redisConnection @sadd("URLs", url)
			return token
		)
	)
	
	generateToken := method(
		token := Sequence clone
		tokenLength repeat(
			token = token appendSeq(characters at(Random value(characters size) round) asCharacter)
		)
		return token
	)
)
