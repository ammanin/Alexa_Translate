LangList.delete_all
TranList.delete_all
LangList.create!([{lang_name: "afrikaans", lang_code: "af"}])
LangList.create!([{lang_name: "latin", lang_code: "bs-Latn"}])
LangList.create!([{lang_name: "catalan", lang_code: "ca"}])
LangList.create!([{lang_name: "bulgarian", lang_code: "bg"}])
LangList.create!([{lang_name: "czech", lang_code: "cs"}])
LangList.create!([{lang_name: "danish", lang_code: "da"}])
LangList.create!([{lang_name: "dutch", lang_code: "nl"}])
LangList.create!([{lang_name: "estonian", lang_code: "et"}])
LangList.create!([{lang_name: "finnish", lang_code: "fi"}])
LangList.create!([{lang_name: "french", lang_code: "fr"}])
LangList.create!([{lang_name: "german", lang_code: "de"}])
LangList.create!([{lang_name: "italian", lang_code: "it"}])
LangList.create!([{lang_name: "portuguese", lang_code: "pt"}])
LangList.create!([{lang_name: "spanish", lang_code: "es"}])
LangList.create!([{lang_name: "welsch", lang_code: "cy"}])

TranList.create!([{lang: "german", phrase: "where are you from", tras: "woher komme sie"}])
