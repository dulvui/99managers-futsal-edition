# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorWorld


func init_world() -> World:
	# always reset IdUtil, when new world is created
	IdUtil.reset()

	var world: World = World.new()

	# continents
	var africa: Continent = Continent.new()
	var asia: Continent = Continent.new()
	var europe: Continent = Continent.new()
	var south_america: Continent = Continent.new()
	var north_america: Continent = Continent.new()
	var oceania: Continent = Continent.new()

	africa.name = tr("Africa")
	asia.name = tr("Asia")
	europe.name = tr("Europe")
	south_america.name = tr("South America")
	north_america.name = tr("North America")
	oceania.name = tr("Oceania")

	africa.code = "AF"
	asia.code = "AS"
	europe.code = "EU"
	south_america.code = "SA"
	north_america.code = "NA"
	oceania.code = "OC"

	world.continents.append(africa)
	world.continents.append(asia)
	world.continents.append(europe)
	world.continents.append(south_america)
	world.continents.append(north_america)
	world.continents.append(oceania)

	# Afghanistan
	var af : Nation = Nation.new()
	af.name = tr("Afghanistan")
	af.code = "AF"
	asia.nations.append(af)
	af.locales = [
		Locale.new("Pashto", "ps"),
		Locale.new("Uzbek", "uz"),
		Locale.new("Turkmen", "tk")
	]
	af.borders = [
		"IR", "PK", "TM", "UZ", "TJ", "CN"
	]

	# Egypt
	var eg : Nation = Nation.new()
	eg.name = tr("Egypt")
	eg.code = "EG"
	africa.nations.append(eg)
	eg.locales = [
		Locale.new("Arabic", "ar")
	]
	eg.borders = [
		"IL", "LY", "PS", "SD"
	]

	# Albania
	var al : Nation = Nation.new()
	al.name = tr("Albania")
	al.code = "AL"
	europe.nations.append(al)
	al.locales = [
		Locale.new("Albanian", "sq")
	]
	al.borders = [
		"ME", "GR", "MK", "XK"
	]

	# Algeria
	var dz : Nation = Nation.new()
	dz.name = tr("Algeria")
	dz.code = "DZ"
	africa.nations.append(dz)
	dz.locales = [
		Locale.new("Arabic", "ar")
	]
	dz.borders = [
		"TN", "LY", "NE", "EH", "MR", "ML", "MA"
	]

	# Andorra
	var ad : Nation = Nation.new()
	ad.name = tr("Andorra")
	ad.code = "AD"
	europe.nations.append(ad)
	ad.locales = [
		Locale.new("Catalan", "ca")
	]
	ad.borders = [
		"FR", "ES"
	]

	# Angola
	var ao : Nation = Nation.new()
	ao.name = tr("Angola")
	ao.code = "AO"
	africa.nations.append(ao)
	ao.locales = [
		Locale.new("Portuguese", "pt")
	]
	ao.borders = [
		"CG", "CD", "ZM", "NA"
	]

	# Antigua and Barbuda
	var ag : Nation = Nation.new()
	ag.name = tr("Antigua and Barbuda")
	ag.code = "AG"
	north_america.nations.append(ag)
	ag.locales = [
		Locale.new("English", "en")
	]

	# Equatorial Guinea
	var gq : Nation = Nation.new()
	gq.name = tr("Equatorial Guinea")
	gq.code = "GQ"
	africa.nations.append(gq)
	gq.locales = [
		Locale.new("Spanish", "es"),
		Locale.new("French", "fr"),
		Locale.new("Portuguese", "pt"),
		Locale.new("Fang", "")
	]
	gq.borders = [
		"CM", "GA"
	]

	# Argentina
	var ar : Nation = Nation.new()
	ar.name = tr("Argentina")
	ar.code = "AR"
	south_america.nations.append(ar)
	ar.locales = [
		Locale.new("Spanish", "es"),
		Locale.new("Guaraní", "gn")
	]
	ar.borders = [
		"BO", "BR", "CL", "PY", "UY"
	]

	# Armenia
	var am : Nation = Nation.new()
	am.name = tr("Armenia")
	am.code = "AM"
	asia.nations.append(am)
	am.locales = [
		Locale.new("Armenian", "hy")
	]
	am.borders = [
		"AZ", "GE", "IR", "TR"
	]

	# Azerbaijan
	var az : Nation = Nation.new()
	az.name = tr("Azerbaijan")
	az.code = "AZ"
	asia.nations.append(az)
	az.locales = [
		Locale.new("Azerbaijani", "az")
	]
	az.borders = [
		"AM", "GE", "IR", "RU", "TR"
	]

	# Ethiopia
	var et : Nation = Nation.new()
	et.name = tr("Ethiopia")
	et.code = "ET"
	africa.nations.append(et)
	et.locales = [
		Locale.new("Amharic", "am")
	]
	et.borders = [
		"DJ", "ER", "KE", "SO", "SS", "SD"
	]

	# Australia
	var au : Nation = Nation.new()
	au.name = tr("Australia")
	au.code = "AU"
	oceania.nations.append(au)
	au.locales = [
		Locale.new("English", "en")
	]

	# Bahamas
	var bs : Nation = Nation.new()
	bs.name = tr("Bahamas")
	bs.code = "BS"
	north_america.nations.append(bs)
	bs.locales = [
		Locale.new("English", "en")
	]

	# Bahrain
	var bh : Nation = Nation.new()
	bh.name = tr("Bahrain")
	bh.code = "BH"
	asia.nations.append(bh)
	bh.locales = [
		Locale.new("Arabic", "ar")
	]

	# Bangladesh
	var bd : Nation = Nation.new()
	bd.name = tr("Bangladesh")
	bd.code = "BD"
	asia.nations.append(bd)
	bd.locales = [
		Locale.new("Bengali", "bn")
	]
	bd.borders = [
		"MM", "IN"
	]

	# Barbados
	var bb : Nation = Nation.new()
	bb.name = tr("Barbados")
	bb.code = "BB"
	north_america.nations.append(bb)
	bb.locales = [
		Locale.new("English", "en")
	]

	# Belarus
	var by : Nation = Nation.new()
	by.name = tr("Belarus")
	by.code = "BY"
	europe.nations.append(by)
	by.locales = [
		Locale.new("Belarusian", "be"),
		Locale.new("Russian", "ru")
	]
	by.borders = [
		"LV", "LT", "PL", "RU", "UA"
	]

	# Belgium
	var be : Nation = Nation.new()
	be.name = tr("Belgium")
	be.code = "BE"
	europe.nations.append(be)
	be.locales = [
		Locale.new("Dutch", "nl"),
		Locale.new("French", "fr"),
		Locale.new("German", "de")
	]
	be.borders = [
		"FR", "DE", "LU", "NL"
	]

	# Belize
	var bz : Nation = Nation.new()
	bz.name = tr("Belize")
	bz.code = "BZ"
	north_america.nations.append(bz)
	bz.locales = [
		Locale.new("English", "en"),
		Locale.new("Spanish", "es")
	]
	bz.borders = [
		"GT", "MX"
	]

	# Benin
	var bj : Nation = Nation.new()
	bj.name = tr("Benin")
	bj.code = "BJ"
	africa.nations.append(bj)
	bj.locales = [
		Locale.new("French", "fr")
	]
	bj.borders = [
		"BF", "NE", "NG", "TG"
	]

	# Bhutan
	var bt : Nation = Nation.new()
	bt.name = tr("Bhutan")
	bt.code = "BT"
	asia.nations.append(bt)
	bt.locales = [
		Locale.new("Dzongkha", "dz")
	]
	bt.borders = [
		"CN", "IN"
	]

	# Bolivia
	var bo : Nation = Nation.new()
	bo.name = tr("Bolivia")
	bo.code = "BO"
	south_america.nations.append(bo)
	bo.locales = [
		Locale.new("Spanish", "es"),
		Locale.new("Aymara", "ay"),
		Locale.new("Quechua", "qu")
	]
	bo.borders = [
		"AR", "BR", "CL", "PY", "PE"
	]

	# Bosnia and Herzegovina
	var ba : Nation = Nation.new()
	ba.name = tr("Bosnia and Herzegovina")
	ba.code = "BA"
	europe.nations.append(ba)
	ba.locales = [
		Locale.new("Bosnian", "bs"),
		Locale.new("Croatian", "hr"),
		Locale.new("Serbian", "sr")
	]
	ba.borders = [
		"HR", "ME", "RS"
	]

	# Botswana
	var bw : Nation = Nation.new()
	bw.name = tr("Botswana")
	bw.code = "BW"
	africa.nations.append(bw)
	bw.locales = [
		Locale.new("English", "en"),
		Locale.new("Tswana", "tn")
	]
	bw.borders = [
		"NA", "ZA", "ZM", "ZW"
	]

	# Brazil
	var br : Nation = Nation.new()
	br.name = tr("Brazil")
	br.code = "BR"
	south_america.nations.append(br)
	br.locales = [
		Locale.new("Portuguese", "pt")
	]
	br.borders = [
		"AR", "BO", "CO", "GF", "GY", "PY", "PE", "SR", "UY", "VE"
	]

	# Brunei
	var bn : Nation = Nation.new()
	bn.name = tr("Brunei")
	bn.code = "BN"
	asia.nations.append(bn)
	bn.locales = [
		Locale.new("Malay", "ms")
	]
	bn.borders = [
		"MY"
	]

	# Bulgaria
	var bg : Nation = Nation.new()
	bg.name = tr("Bulgaria")
	bg.code = "BG"
	europe.nations.append(bg)
	bg.locales = [
		Locale.new("Bulgarian", "bg")
	]
	bg.borders = [
		"GR", "MK", "RO", "RS", "TR"
	]

	# Burkina Faso
	var bf : Nation = Nation.new()
	bf.name = tr("Burkina Faso")
	bf.code = "BF"
	africa.nations.append(bf)
	bf.locales = [
		Locale.new("French", "fr"),
		Locale.new("Fula", "ff")
	]
	bf.borders = [
		"BJ", "CI", "GH", "ML", "NE", "TG"
	]

	# Burundi
	var bi : Nation = Nation.new()
	bi.name = tr("Burundi")
	bi.code = "BI"
	africa.nations.append(bi)
	bi.locales = [
		Locale.new("French", "fr"),
		Locale.new("Kirundi", "rn")
	]
	bi.borders = [
		"CD", "RW", "TZ"
	]

	# Chile
	var cl : Nation = Nation.new()
	cl.name = tr("Chile")
	cl.code = "CL"
	south_america.nations.append(cl)
	cl.locales = [
		Locale.new("Spanish", "es")
	]
	cl.borders = [
		"AR", "BO", "PE"
	]

	# China
	var cn : Nation = Nation.new()
	cn.name = tr("China")
	cn.code = "CN"
	asia.nations.append(cn)
	cn.locales = [
		Locale.new("Chinese", "zh")
	]
	cn.borders = [
		"AF",
		"BT",
		"MM",
		"HK",
		"IN",
		"KZ",
		"NP",
		"KP",
		"KG",
		"LA",
		"MO",
		"MN",
		"PK",
		"RU",
		"TJ",
		"VN"
	]

	# Costa Rica
	var cr : Nation = Nation.new()
	cr.name = tr("Costa Rica")
	cr.code = "CR"
	north_america.nations.append(cr)
	cr.locales = [
		Locale.new("Spanish", "es")
	]
	cr.borders = [
		"NI", "PA"
	]

	# Denmark
	var dk : Nation = Nation.new()
	dk.name = tr("Denmark")
	dk.code = "DK"
	europe.nations.append(dk)
	dk.locales = [
		Locale.new("Danish", "da")
	]
	dk.borders = [
		"DE"
	]

	# Democratic Republic of the Congo
	var cd : Nation = Nation.new()
	cd.name = tr("Democratic Republic of the Congo")
	cd.code = "CD"
	africa.nations.append(cd)
	cd.locales = [
		Locale.new("French", "fr"),
		Locale.new("Lingala", "ln"),
		Locale.new("Kongo", "kg"),
		Locale.new("Swahili", "sw"),
		Locale.new("Luba-Katanga", "lu")
	]
	cd.borders = [
		"AO", "BI", "CF", "CG", "RW", "SS", "TZ", "UG", "ZM"
	]

	# Germany
	var de : Nation = Nation.new()
	de.name = tr("Germany")
	de.code = "DE"
	europe.nations.append(de)
	de.locales = [
		Locale.new("German", "de")
	]
	de.borders = [
		"AT", "BE", "CZ", "DK", "FR", "LU", "NL", "PL", "CH"
	]

	# Dominica
	var dm : Nation = Nation.new()
	dm.name = tr("Dominica")
	dm.code = "DM"
	north_america.nations.append(dm)
	dm.locales = [
		Locale.new("English", "en")
	]

	# Dominican Republic
	var do : Nation = Nation.new()
	do.name = tr("Dominican Republic")
	do.code = "DO"
	north_america.nations.append(do)
	do.locales = [
		Locale.new("Spanish", "es")
	]
	do.borders = [
		"HT"
	]

	# Djibouti
	var dj : Nation = Nation.new()
	dj.name = tr("Djibouti")
	dj.code = "DJ"
	africa.nations.append(dj)
	dj.locales = [
		Locale.new("French", "fr"),
		Locale.new("Arabic", "ar")
	]
	dj.borders = [
		"ER", "ET", "SO"
	]

	# Ecuador
	var ec : Nation = Nation.new()
	ec.name = tr("Ecuador")
	ec.code = "EC"
	south_america.nations.append(ec)
	ec.locales = [
		Locale.new("Spanish", "es")
	]
	ec.borders = [
		"CO", "PE"
	]

	# El Salvador
	var sv : Nation = Nation.new()
	sv.name = tr("El Salvador")
	sv.code = "SV"
	north_america.nations.append(sv)
	sv.locales = [
		Locale.new("Spanish", "es")
	]
	sv.borders = [
		"GT", "HN"
	]

	# Côte d'Ivoire
	var ci : Nation = Nation.new()
	ci.name = tr("Côte d'Ivoire")
	ci.code = "CI"
	africa.nations.append(ci)
	ci.locales = [
		Locale.new("French", "fr")
	]
	ci.borders = [
		"BF", "GH", "GN", "LR", "ML"
	]

	# Eritrea
	var er : Nation = Nation.new()
	er.name = tr("Eritrea")
	er.code = "ER"
	africa.nations.append(er)
	er.locales = [
		Locale.new("Tigrinya", "ti"),
		Locale.new("Arabic", "ar"),
		Locale.new("English", "en"),
		Locale.new("Tigre", ""),
		Locale.new("Kunama", ""),
		Locale.new("Saho", ""),
		Locale.new("Bilen", ""),
		Locale.new("Nara", ""),
		Locale.new("Afar", "aa")
	]
	er.borders = [
		"DJ", "ET", "SD"
	]

	# Estonia
	var ee : Nation = Nation.new()
	ee.name = tr("Estonia")
	ee.code = "EE"
	europe.nations.append(ee)
	ee.locales = [
		Locale.new("Estonian", "et")
	]
	ee.borders = [
		"LV", "RU"
	]

	# Eswatini
	var sz : Nation = Nation.new()
	sz.name = tr("Eswatini")
	sz.code = "SZ"
	africa.nations.append(sz)
	sz.locales = [
		Locale.new("English", "en"),
		Locale.new("Swati", "ss")
	]
	sz.borders = [
		"MZ", "ZA"
	]

	# Fiji
	var fj : Nation = Nation.new()
	fj.name = tr("Fiji")
	fj.code = "FJ"
	oceania.nations.append(fj)
	fj.locales = [
		Locale.new("English", "en"),
		Locale.new("Fijian", "fj"),
		Locale.new("Fiji Hindi", ""),
		Locale.new("Rotuman", "")
	]

	# Finland
	var fi : Nation = Nation.new()
	fi.name = tr("Finland")
	fi.code = "FI"
	europe.nations.append(fi)
	fi.locales = [
		Locale.new("Finnish", "fi"),
		Locale.new("Swedish", "sv")
	]
	fi.borders = [
		"NO", "SE", "RU"
	]

	# Micronesia
	var fm : Nation = Nation.new()
	fm.name = tr("Micronesia")
	fm.code = "FM"
	oceania.nations.append(fm)
	fm.locales = [
		Locale.new("English", "en")
	]

	# France
	var fr : Nation = Nation.new()
	fr.name = tr("France")
	fr.code = "FR"
	europe.nations.append(fr)
	fr.locales = [
		Locale.new("French", "fr")
	]
	fr.borders = [
		"AD", "BE", "DE", "IT", "LU", "MC", "ES", "CH"
	]

	# Monaco
	var mc : Nation = Nation.new()
	mc.name = tr("Monaco")
	mc.code = "MC"
	europe.nations.append(mc)
	mc.locales = [
		Locale.new("French", "fr")
	]
	mc.borders = [
		"FR"
	]

	# Gabon
	var ga : Nation = Nation.new()
	ga.name = tr("Gabon")
	ga.code = "GA"
	africa.nations.append(ga)
	ga.locales = [
		Locale.new("French", "fr")
	]
	ga.borders = [
		"CM", "CG", "GQ"
	]

	# Gambia
	var gm : Nation = Nation.new()
	gm.name = tr("Gambia")
	gm.code = "GM"
	africa.nations.append(gm)
	gm.locales = [
		Locale.new("English", "en")
	]
	gm.borders = [
		"SN"
	]

	# Georgia
	var ge : Nation = Nation.new()
	ge.name = tr("Georgia")
	ge.code = "GE"
	asia.nations.append(ge)
	ge.locales = [
		Locale.new("Georgian", "ka")
	]
	ge.borders = [
		"AM", "AZ", "RU", "TR"
	]

	# Ghana
	var gh : Nation = Nation.new()
	gh.name = tr("Ghana")
	gh.code = "GH"
	africa.nations.append(gh)
	gh.locales = [
		Locale.new("English", "en")
	]
	gh.borders = [
		"BF", "CI", "TG"
	]

	# Grenada
	var gd : Nation = Nation.new()
	gd.name = tr("Grenada")
	gd.code = "GD"
	north_america.nations.append(gd)
	gd.locales = [
		Locale.new("English", "en")
	]

	# Greece
	var gr : Nation = Nation.new()
	gr.name = tr("Greece")
	gr.code = "GR"
	europe.nations.append(gr)
	gr.locales = [
		Locale.new("Greek", "el")
	]
	gr.borders = [
		"AL", "BG", "TR", "MK"
	]

	# Guatemala
	var gt : Nation = Nation.new()
	gt.name = tr("Guatemala")
	gt.code = "GT"
	north_america.nations.append(gt)
	gt.locales = [
		Locale.new("Spanish", "es")
	]
	gt.borders = [
		"BZ", "SV", "HN", "MX"
	]

	# Guinea
	var gn : Nation = Nation.new()
	gn.name = tr("Guinea")
	gn.code = "GN"
	africa.nations.append(gn)
	gn.locales = [
		Locale.new("French", "fr"),
		Locale.new("Fula", "ff")
	]
	gn.borders = [
		"CI", "GW", "LR", "ML", "SN", "SL"
	]

	# Guinea-Bissau
	var gw : Nation = Nation.new()
	gw.name = tr("Guinea-Bissau")
	gw.code = "GW"
	africa.nations.append(gw)
	gw.locales = [
		Locale.new("Portuguese", "pt")
	]
	gw.borders = [
		"GN", "SN"
	]

	# Guyana
	var gy : Nation = Nation.new()
	gy.name = tr("Guyana")
	gy.code = "GY"
	south_america.nations.append(gy)
	gy.locales = [
		Locale.new("English", "en")
	]
	gy.borders = [
		"BR", "SR", "VE"
	]

	# Haiti
	var ht : Nation = Nation.new()
	ht.name = tr("Haiti")
	ht.code = "HT"
	north_america.nations.append(ht)
	ht.locales = [
		Locale.new("French", "fr"),
		Locale.new("Haitian", "ht")
	]
	ht.borders = [
		"DO"
	]

	# Honduras
	var hn : Nation = Nation.new()
	hn.name = tr("Honduras")
	hn.code = "HN"
	north_america.nations.append(hn)
	hn.locales = [
		Locale.new("Spanish", "es")
	]
	hn.borders = [
		"GT", "SV", "NI"
	]

	# India
	var ind : Nation = Nation.new()
	ind.name = tr("India")
	ind.code = "IN"
	asia.nations.append(ind)
	ind.locales = [
		Locale.new("Hindi", "hi"),
		Locale.new("English", "en")
	]
	ind.borders = [
		"BD", "BT", "MM", "CN", "NP", "PK"
	]

	# Indonesia
	var id : Nation = Nation.new()
	id.name = tr("Indonesia")
	id.code = "ID"
	asia.nations.append(id)
	id.locales = [
		Locale.new("Indonesian", "id")
	]
	id.borders = [
		"TL", "MY", "PG"
	]

	# Iraq
	var iq : Nation = Nation.new()
	iq.name = tr("Iraq")
	iq.code = "IQ"
	asia.nations.append(iq)
	iq.locales = [
		Locale.new("Arabic", "ar"),
		Locale.new("Kurdish", "ku")
	]
	iq.borders = [
		"IR", "JO", "KW", "SA", "SY", "TR"
	]

	# Iran
	var ir : Nation = Nation.new()
	ir.name = tr("Iran")
	ir.code = "IR"
	asia.nations.append(ir)
	ir.locales = [
		Locale.new("Persian (Farsi)", "fa")
	]
	ir.borders = [
		"AF", "AM", "AZ", "IQ", "PK", "TR", "TM"
	]

	# Ireland
	var ie : Nation = Nation.new()
	ie.name = tr("Ireland")
	ie.code = "IE"
	europe.nations.append(ie)
	ie.locales = [
		Locale.new("Irish", "ga"),
		Locale.new("English", "en")
	]
	ie.borders = [
		"GB"
	]

	# Iceland
	var ice : Nation = Nation.new()
	ice.name = tr("Iceland")
	ice.code = "IS"
	europe.nations.append(ice)
	ice.locales = [
		Locale.new("Icelandic", "is")
	]

	# Israel
	var il : Nation = Nation.new()
	il.name = tr("Israel")
	il.code = "IL"
	asia.nations.append(il)
	il.locales = [
		Locale.new("Hebrew", "he"),
		Locale.new("Arabic", "ar")
	]
	il.borders = [
		"EG", "JO", "LB", "PS", "SY"
	]

	# Italy
	var it : Nation = Nation.new()
	it.name = tr("Italy")
	it.code = "IT"
	europe.nations.append(it)
	it.locales = [
		Locale.new("Italian", "it")
	]
	it.borders = [
		"AT", "FR", "SM", "SI", "CH", "VA"
	]

	# Jamaica
	var jm : Nation = Nation.new()
	jm.name = tr("Jamaica")
	jm.code = "JM"
	north_america.nations.append(jm)
	jm.locales = [
		Locale.new("English", "en")
	]

	# Japan
	var jp : Nation = Nation.new()
	jp.name = tr("Japan")
	jp.code = "JP"
	asia.nations.append(jp)
	jp.locales = [
		Locale.new("Japanese", "ja")
	]

	# Yemen
	var ye : Nation = Nation.new()
	ye.name = tr("Yemen")
	ye.code = "YE"
	asia.nations.append(ye)
	ye.locales = [
		Locale.new("Arabic", "ar")
	]
	ye.borders = [
		"OM", "SA"
	]

	# Jordan
	var jo : Nation = Nation.new()
	jo.name = tr("Jordan")
	jo.code = "JO"
	asia.nations.append(jo)
	jo.locales = [
		Locale.new("Arabic", "ar")
	]
	jo.borders = [
		"IQ", "IL", "PS", "SA", "SY"
	]

	# Cambodia
	var kh : Nation = Nation.new()
	kh.name = tr("Cambodia")
	kh.code = "KH"
	asia.nations.append(kh)
	kh.locales = [
		Locale.new("Khmer", "km")
	]
	kh.borders = [
		"LA", "TH", "VN"
	]

	# Cameroon
	var cm : Nation = Nation.new()
	cm.name = tr("Cameroon")
	cm.code = "CM"
	africa.nations.append(cm)
	cm.locales = [
		Locale.new("English", "en"),
		Locale.new("French", "fr")
	]
	cm.borders = [
		"CF", "TD", "CG", "GQ", "GA", "NG"
	]

	# Canada
	var ca : Nation = Nation.new()
	ca.name = tr("Canada")
	ca.code = "CA"
	north_america.nations.append(ca)
	ca.locales = [
		Locale.new("English", "en"),
		Locale.new("French", "fr")
	]
	ca.borders = [
		"US"
	]

	# Cabo Verde
	var cv : Nation = Nation.new()
	cv.name = tr("Cabo Verde")
	cv.code = "CV"
	africa.nations.append(cv)
	cv.locales = [
		Locale.new("Portuguese", "pt")
	]

	# Kazakhstan
	var kz : Nation = Nation.new()
	kz.name = tr("Kazakhstan")
	kz.code = "KZ"
	asia.nations.append(kz)
	kz.locales = [
		Locale.new("Kazakh", "kk"),
		Locale.new("Russian", "ru")
	]
	kz.borders = [
		"CN", "KG", "RU", "TM", "UZ"
	]

	# Qatar
	var qa : Nation = Nation.new()
	qa.name = tr("Qatar")
	qa.code = "QA"
	asia.nations.append(qa)
	qa.locales = [
		Locale.new("Arabic", "ar")
	]
	qa.borders = [
		"SA"
	]

	# Kenya
	var ke : Nation = Nation.new()
	ke.name = tr("Kenya")
	ke.code = "KE"
	africa.nations.append(ke)
	ke.locales = [
		Locale.new("English", "en"),
		Locale.new("Swahili", "sw")
	]
	ke.borders = [
		"ET", "SO", "SS", "TZ", "UG"
	]

	# Kyrgyzstan
	var kg : Nation = Nation.new()
	kg.name = tr("Kyrgyzstan")
	kg.code = "KG"
	asia.nations.append(kg)
	kg.locales = [
		Locale.new("Kyrgyz", "ky"),
		Locale.new("Russian", "ru")
	]
	kg.borders = [
		"CN", "KZ", "TJ", "UZ"
	]

	# Kiribati
	var ki : Nation = Nation.new()
	ki.name = tr("Kiribati")
	ki.code = "KI"
	oceania.nations.append(ki)
	ki.locales = [
		Locale.new("English", "en")
	]

	# Colombia
	var co : Nation = Nation.new()
	co.name = tr("Colombia")
	co.code = "CO"
	south_america.nations.append(co)
	co.locales = [
		Locale.new("Spanish", "es")
	]
	co.borders = [
		"BR", "EC", "PA", "PE", "VE"
	]

	# Comoros
	var km : Nation = Nation.new()
	km.name = tr("Comoros")
	km.code = "KM"
	africa.nations.append(km)
	km.locales = [
		Locale.new("Arabic", "ar"),
		Locale.new("French", "fr")
	]

	# Kosovo
	var xk : Nation = Nation.new()
	xk.name = tr("Kosovo")
	xk.code = "XK"
	europe.nations.append(xk)
	xk.locales = [
		Locale.new("Albanian", "sq"),
		Locale.new("Serbian", "sr")
	]
	xk.borders = [
		"AL", "MK", "ME", "RS"
	]

	# Croatia
	var hr : Nation = Nation.new()
	hr.name = tr("Croatia")
	hr.code = "HR"
	europe.nations.append(hr)
	hr.locales = [
		Locale.new("Croatian", "hr")
	]
	hr.borders = [
		"BA", "HU", "ME", "RS", "SI"
	]

	# Cuba
	var cu : Nation = Nation.new()
	cu.name = tr("Cuba")
	cu.code = "CU"
	north_america.nations.append(cu)
	cu.locales = [
		Locale.new("Spanish", "es")
	]

	# Kuwait
	var kw : Nation = Nation.new()
	kw.name = tr("Kuwait")
	kw.code = "KW"
	asia.nations.append(kw)
	kw.locales = [
		Locale.new("Arabic", "ar")
	]
	kw.borders = [
		"IQ", "SA"
	]

	# Laos
	var la : Nation = Nation.new()
	la.name = tr("Laos")
	la.code = "LA"
	asia.nations.append(la)
	la.locales = [
		Locale.new("Lao", "lo")
	]
	la.borders = [
		"MM", "KH", "CN", "TH", "VN"
	]

	# Lesotho
	var ls : Nation = Nation.new()
	ls.name = tr("Lesotho")
	ls.code = "LS"
	africa.nations.append(ls)
	ls.locales = [
		Locale.new("English", "en"),
		Locale.new("Southern Sotho", "st")
	]
	ls.borders = [
		"ZA"
	]

	# Latvia
	var lv : Nation = Nation.new()
	lv.name = tr("Latvia")
	lv.code = "LV"
	europe.nations.append(lv)
	lv.locales = [
		Locale.new("Latvian", "lv")
	]
	lv.borders = [
		"BY", "EE", "LT", "RU"
	]

	# Lebanon
	var lb : Nation = Nation.new()
	lb.name = tr("Lebanon")
	lb.code = "LB"
	asia.nations.append(lb)
	lb.locales = [
		Locale.new("Arabic", "ar"),
		Locale.new("French", "fr")
	]
	lb.borders = [
		"IL", "SY"
	]

	# Liberia
	var lr : Nation = Nation.new()
	lr.name = tr("Liberia")
	lr.code = "LR"
	africa.nations.append(lr)
	lr.locales = [
		Locale.new("English", "en")
	]
	lr.borders = [
		"GN", "CI", "SL"
	]

	# Libya
	var ly : Nation = Nation.new()
	ly.name = tr("Libya")
	ly.code = "LY"
	africa.nations.append(ly)
	ly.locales = [
		Locale.new("Arabic", "ar")
	]
	ly.borders = [
		"DZ", "TD", "EG", "NE", "SD", "TN"
	]

	# Liechtenstein
	var li : Nation = Nation.new()
	li.name = tr("Liechtenstein")
	li.code = "LI"
	europe.nations.append(li)
	li.locales = [
		Locale.new("German", "de")
	]
	li.borders = [
		"AT", "CH"
	]

	# Lithuania
	var lt : Nation = Nation.new()
	lt.name = tr("Lithuania")
	lt.code = "LT"
	europe.nations.append(lt)
	lt.locales = [
		Locale.new("Lithuanian", "lt")
	]
	lt.borders = [
		"BY", "LV", "PL", "RU"
	]

	# Luxembourg
	var lu : Nation = Nation.new()
	lu.name = tr("Luxembourg")
	lu.code = "LU"
	europe.nations.append(lu)
	lu.locales = [
		Locale.new("French", "fr"),
		Locale.new("German", "de"),
		Locale.new("Luxembourgish", "lb")
	]
	lu.borders = [
		"BE", "FR", "DE"
	]

	# Madagascar
	var mg : Nation = Nation.new()
	mg.name = tr("Madagascar")
	mg.code = "MG"
	africa.nations.append(mg)
	mg.locales = [
		Locale.new("French", "fr"),
		Locale.new("Malagasy", "mg")
	]

	# Malawi
	var mw : Nation = Nation.new()
	mw.name = tr("Malawi")
	mw.code = "MW"
	africa.nations.append(mw)
	mw.locales = [
		Locale.new("English", "en"),
		Locale.new("Chichewa", "ny")
	]
	mw.borders = [
		"MZ", "TZ", "ZM"
	]

	# Malaysia
	var my : Nation = Nation.new()
	my.name = tr("Malaysia")
	my.code = "MY"
	asia.nations.append(my)
	my.locales = [
		Locale.new("Malaysian", "ms")
	]
	my.borders = [
		"BN", "ID", "TH"
	]

	# Maldives
	var mv : Nation = Nation.new()
	mv.name = tr("Maldives")
	mv.code = "MV"
	asia.nations.append(mv)
	mv.locales = [
		Locale.new("Maldivian", "dv")
	]

	# Mali
	var ml : Nation = Nation.new()
	ml.name = tr("Mali")
	ml.code = "ML"
	africa.nations.append(ml)
	ml.locales = [
		Locale.new("French", "fr")
	]
	ml.borders = [
		"DZ", "BF", "GN", "CI", "MR", "NE", "SN"
	]

	# Malta
	var mt : Nation = Nation.new()
	mt.name = tr("Malta")
	mt.code = "MT"
	europe.nations.append(mt)
	mt.locales = [
		Locale.new("Maltese", "mt"),
		Locale.new("English", "en")
	]

	# Morocco
	var ma : Nation = Nation.new()
	ma.name = tr("Morocco")
	ma.code = "MA"
	africa.nations.append(ma)
	ma.locales = [
		Locale.new("Arabic", "ar")
	]
	ma.borders = [
		"DZ", "EH", "ES"
	]

	# Marshall Islands
	var mh : Nation = Nation.new()
	mh.name = tr("Marshall Islands")
	mh.code = "MH"
	oceania.nations.append(mh)
	mh.locales = [
		Locale.new("English", "en"),
		Locale.new("Marshallese", "mh")
	]

	# Mauritania
	var mr : Nation = Nation.new()
	mr.name = tr("Mauritania")
	mr.code = "MR"
	africa.nations.append(mr)
	mr.locales = [
		Locale.new("Arabic", "ar")
	]
	mr.borders = [
		"DZ", "ML", "SN", "EH"
	]

	# Mauritius
	var mu : Nation = Nation.new()
	mu.name = tr("Mauritius")
	mu.code = "MU"
	africa.nations.append(mu)
	mu.locales = [
		Locale.new("English", "en")
	]

	# Mexico
	var mx : Nation = Nation.new()
	mx.name = tr("Mexico")
	mx.code = "MX"
	north_america.nations.append(mx)
	mx.locales = [
		Locale.new("Spanish", "es")
	]
	mx.borders = [
		"BZ", "GT", "US"
	]

	# Moldova
	var md : Nation = Nation.new()
	md.name = tr("Moldova")
	md.code = "MD"
	europe.nations.append(md)
	md.locales = [
		Locale.new("Romanian", "ro")
	]
	md.borders = [
		"RO", "UA"
	]

	# Mongolia
	var mn : Nation = Nation.new()
	mn.name = tr("Mongolia")
	mn.code = "MN"
	asia.nations.append(mn)
	mn.locales = [
		Locale.new("Mongolian", "mn")
	]
	mn.borders = [
		"CN", "RU"
	]

	# Montenegro
	var me : Nation = Nation.new()
	me.name = tr("Montenegro")
	me.code = "ME"
	europe.nations.append(me)
	me.locales = [
		Locale.new("Serbian", "sr"),
		Locale.new("Bosnian", "bs"),
		Locale.new("Albanian", "sq"),
		Locale.new("Croatian", "hr")
	]
	me.borders = [
		"AL", "BA", "HR", "XK", "RS"
	]

	# Mozambique
	var mz : Nation = Nation.new()
	mz.name = tr("Mozambique")
	mz.code = "MZ"
	africa.nations.append(mz)
	mz.locales = [
		Locale.new("Portuguese", "pt")
	]
	mz.borders = [
		"MW", "ZA", "SZ", "TZ", "ZM", "ZW"
	]

	# Myanmar
	var mm : Nation = Nation.new()
	mm.name = tr("Myanmar")
	mm.code = "MM"
	asia.nations.append(mm)
	mm.locales = [
		Locale.new("Burmese", "my")
	]
	mm.borders = [
		"BD", "CN", "IN", "LA", "TH"
	]

	# Namibia
	var na : Nation = Nation.new()
	na.name = tr("Namibia")
	na.code = "NA"
	africa.nations.append(na)
	na.locales = [
		Locale.new("English", "en"),
		Locale.new("Afrikaans", "af")
	]
	na.borders = [
		"AO", "BW", "ZA", "ZM"
	]

	# Nauru
	var nr : Nation = Nation.new()
	nr.name = tr("Nauru")
	nr.code = "NR"
	oceania.nations.append(nr)
	nr.locales = [
		Locale.new("English", "en"),
		Locale.new("Nauruan", "na")
	]

	# Nepal
	var np : Nation = Nation.new()
	np.name = tr("Nepal")
	np.code = "NP"
	asia.nations.append(np)
	np.locales = [
		Locale.new("Nepali", "ne")
	]
	np.borders = [
		"CN", "IN"
	]

	# New Zealand
	var nz : Nation = Nation.new()
	nz.name = tr("New Zealand")
	nz.code = "NZ"
	oceania.nations.append(nz)
	nz.locales = [
		Locale.new("English", "en"),
		Locale.new("Māori", "mi")
	]

	# Nicaragua
	var ni : Nation = Nation.new()
	ni.name = tr("Nicaragua")
	ni.code = "NI"
	north_america.nations.append(ni)
	ni.locales = [
		Locale.new("Spanish", "es")
	]
	ni.borders = [
		"CR", "HN"
	]

	# Netherlands
	var nl : Nation = Nation.new()
	nl.name = tr("Netherlands")
	nl.code = "NL"
	europe.nations.append(nl)
	nl.locales = [
		Locale.new("Dutch", "nl")
	]
	nl.borders = [
		"BE", "DE"
	]

	# Niger
	var ne : Nation = Nation.new()
	ne.name = tr("Niger")
	ne.code = "NE"
	africa.nations.append(ne)
	ne.locales = [
		Locale.new("French", "fr")
	]
	ne.borders = [
		"DZ", "BJ", "BF", "TD", "LY", "ML", "NG"
	]

	# Nigeria
	var ng : Nation = Nation.new()
	ng.name = tr("Nigeria")
	ng.code = "NG"
	africa.nations.append(ng)
	ng.locales = [
		Locale.new("English", "en")
	]
	ng.borders = [
		"BJ", "CM", "TD", "NE"
	]

	# North Korea
	var kp : Nation = Nation.new()
	kp.name = tr("North Korea")
	kp.code = "KP"
	asia.nations.append(kp)
	kp.locales = [
		Locale.new("Korean", "ko")
	]
	kp.borders = [
		"CN", "KR", "RU"
	]

	# North Macedonia
	var mk : Nation = Nation.new()
	mk.name = tr("North Macedonia")
	mk.code = "MK"
	europe.nations.append(mk)
	mk.locales = [
		Locale.new("Macedonian", "mk")
	]
	mk.borders = [
		"AL", "BG", "GR", "XK", "RS"
	]

	# Norway
	var no : Nation = Nation.new()
	no.name = tr("Norway")
	no.code = "NO"
	europe.nations.append(no)
	no.locales = [
		Locale.new("Norwegian", "no"),
		Locale.new("Norwegian Bokmål", "nb"),
		Locale.new("Norwegian Nynorsk", "nn")
	]
	no.borders = [
		"FI", "SE", "RU"
	]

	# Oman
	var om : Nation = Nation.new()
	om.name = tr("Oman")
	om.code = "OM"
	asia.nations.append(om)
	om.locales = [
		Locale.new("Arabic", "ar")
	]
	om.borders = [
		"SA", "AE", "YE"
	]

	# Austria
	var at : Nation = Nation.new()
	at.name = tr("Austria")
	at.code = "AT"
	europe.nations.append(at)
	at.locales = [
		Locale.new("German", "de")
	]
	at.borders = [
		"CZ", "DE", "HU", "IT", "LI", "SK", "SI", "CH"
	]

	# Timor-Leste
	var tl : Nation = Nation.new()
	tl.name = tr("Timor-Leste")
	tl.code = "TL"
	asia.nations.append(tl)
	tl.locales = [
		Locale.new("Portuguese", "pt")
	]
	tl.borders = [
		"ID"
	]

	# Pakistan
	var pk : Nation = Nation.new()
	pk.name = tr("Pakistan")
	pk.code = "PK"
	asia.nations.append(pk)
	pk.locales = [
		Locale.new("Urdu", "ur"),
		Locale.new("English", "en")
	]
	pk.borders = [
		"AF", "CN", "IN", "IR"
	]

	# Palestine
	var ps : Nation = Nation.new()
	ps.name = tr("Palestine")
	ps.code = "PS"
	asia.nations.append(ps)
	ps.locales = [
		Locale.new("Arabic", "ar")
	]
	ps.borders = [
		"IL", "EG", "JO"
	]

	# Palau
	var pw : Nation = Nation.new()
	pw.name = tr("Palau")
	pw.code = "PW"
	oceania.nations.append(pw)
	pw.locales = [
		Locale.new("English", "en")
	]

	# Panama
	var pa : Nation = Nation.new()
	pa.name = tr("Panama")
	pa.code = "PA"
	north_america.nations.append(pa)
	pa.locales = [
		Locale.new("Spanish", "es")
	]
	pa.borders = [
		"CO", "CR"
	]

	# Papua New Guinea
	var pg : Nation = Nation.new()
	pg.name = tr("Papua New Guinea")
	pg.code = "PG"
	oceania.nations.append(pg)
	pg.locales = [
		Locale.new("English", "en")
	]
	pg.borders = [
		"ID"
	]

	# Paraguay
	var py : Nation = Nation.new()
	py.name = tr("Paraguay")
	py.code = "PY"
	south_america.nations.append(py)
	py.locales = [
		Locale.new("Spanish", "es"),
		Locale.new("Guaraní", "gn")
	]
	py.borders = [
		"AR", "BO", "BR"
	]

	# Peru
	var pe : Nation = Nation.new()
	pe.name = tr("Peru")
	pe.code = "PE"
	south_america.nations.append(pe)
	pe.locales = [
		Locale.new("Spanish", "es")
	]
	pe.borders = [
		"BO", "BR", "CL", "CO", "EC"
	]

	# Philippines
	var ph : Nation = Nation.new()
	ph.name = tr("Philippines")
	ph.code = "PH"
	asia.nations.append(ph)
	ph.locales = [
		Locale.new("English", "en")
	]

	# Poland
	var pl : Nation = Nation.new()
	pl.name = tr("Poland")
	pl.code = "PL"
	europe.nations.append(pl)
	pl.locales = [
		Locale.new("Polish", "pl")
	]
	pl.borders = [
		"BY", "CZ", "DE", "LT", "RU", "SK", "UA"
	]

	# Portugal
	var pt : Nation = Nation.new()
	pt.name = tr("Portugal")
	pt.code = "PT"
	europe.nations.append(pt)
	pt.locales = [
		Locale.new("Portuguese", "pt")
	]
	pt.borders = [
		"ES"
	]

	# Republic of the Congo
	var cg : Nation = Nation.new()
	cg.name = tr("Republic of the Congo")
	cg.code = "CG"
	africa.nations.append(cg)
	cg.locales = [
		Locale.new("French", "fr"),
		Locale.new("Lingala", "ln")
	]
	cg.borders = [
		"AO", "CM", "CF", "CD", "GA"
	]

	# Rwanda
	var rw : Nation = Nation.new()
	rw.name = tr("Rwanda")
	rw.code = "RW"
	africa.nations.append(rw)
	rw.locales = [
		Locale.new("Kinyarwanda", "rw"),
		Locale.new("English", "en"),
		Locale.new("French", "fr")
	]
	rw.borders = [
		"BI", "CD", "TZ", "UG"
	]

	# Romania
	var ro : Nation = Nation.new()
	ro.name = tr("Romania")
	ro.code = "RO"
	europe.nations.append(ro)
	ro.locales = [
		Locale.new("Romanian", "ro")
	]
	ro.borders = [
		"BG", "HU", "MD", "RS", "UA"
	]

	# Russia
	var ru : Nation = Nation.new()
	ru.name = tr("Russia")
	ru.code = "RU"
	europe.nations.append(ru)
	ru.locales = [
		Locale.new("Russian", "ru")
	]
	ru.borders = [
		"AZ", "BY", "CN", "EE", "FI", "GE", "KZ", "KP", "LV", "LT", "MN", "NO", "PL", "UA"
	]

	# Solomon Islands
	var sb : Nation = Nation.new()
	sb.name = tr("Solomon Islands")
	sb.code = "SB"
	oceania.nations.append(sb)
	sb.locales = [
		Locale.new("English", "en")
	]

	# Zambia
	var zm : Nation = Nation.new()
	zm.name = tr("Zambia")
	zm.code = "ZM"
	africa.nations.append(zm)
	zm.locales = [
		Locale.new("English", "en")
	]
	zm.borders = [
		"AO", "BW", "CD", "MW", "MZ", "NA", "TZ", "ZW"
	]

	# Samoa
	var ws : Nation = Nation.new()
	ws.name = tr("Samoa")
	ws.code = "WS"
	oceania.nations.append(ws)
	ws.locales = [
		Locale.new("Samoan", "sm"),
		Locale.new("English", "en")
	]

	# San Marino
	var sm : Nation = Nation.new()
	sm.name = tr("San Marino")
	sm.code = "SM"
	europe.nations.append(sm)
	sm.locales = [
		Locale.new("Italian", "it")
	]
	sm.borders = [
		"IT"
	]

	# Sao Tome and Principe
	var st : Nation = Nation.new()
	st.name = tr("Sao Tome and Principe")
	st.code = "ST"
	africa.nations.append(st)
	st.locales = [
		Locale.new("Portuguese", "pt")
	]

	# Saudi Arabia
	var sa : Nation = Nation.new()
	sa.name = tr("Saudi Arabia")
	sa.code = "SA"
	asia.nations.append(sa)
	sa.locales = [
		Locale.new("Arabic", "ar")
	]
	sa.borders = [
		"IQ", "JO", "KW", "OM", "QA", "AE", "YE"
	]

	# Sweden
	var se : Nation = Nation.new()
	se.name = tr("Sweden")
	se.code = "SE"
	europe.nations.append(se)
	se.locales = [
		Locale.new("Swedish", "sv")
	]
	se.borders = [
		"FI", "NO"
	]

	# Switzerland
	var ch : Nation = Nation.new()
	ch.name = tr("Switzerland")
	ch.code = "CH"
	europe.nations.append(ch)
	ch.locales = [
		Locale.new("German", "de"),
		Locale.new("French", "fr"),
		Locale.new("Italian", "it"),
		Locale.new("Romansh", "rm")
	]
	ch.borders = [
		"AT", "FR", "IT", "LI", "DE"
	]

	# Senegal
	var sn : Nation = Nation.new()
	sn.name = tr("Senegal")
	sn.code = "SN"
	africa.nations.append(sn)
	sn.locales = [
		Locale.new("French", "fr")
	]
	sn.borders = [
		"GM", "GN", "GW", "ML", "MR"
	]

	# Serbia
	var rs : Nation = Nation.new()
	rs.name = tr("Serbia")
	rs.code = "RS"
	europe.nations.append(rs)
	rs.locales = [
		Locale.new("Serbian", "sr")
	]
	rs.borders = [
		"BA", "BG", "HR", "HU", "XK", "MK", "ME", "RO"
	]

	# Seychelles
	var sc : Nation = Nation.new()
	sc.name = tr("Seychelles")
	sc.code = "SC"
	africa.nations.append(sc)
	sc.locales = [
		Locale.new("French", "fr"),
		Locale.new("English", "en")
	]

	# Sierra Leone
	var sl : Nation = Nation.new()
	sl.name = tr("Sierra Leone")
	sl.code = "SL"
	africa.nations.append(sl)
	sl.locales = [
		Locale.new("English", "en")
	]
	sl.borders = [
		"GN", "LR"
	]

	# Zimbabwe
	var zw : Nation = Nation.new()
	zw.name = tr("Zimbabwe")
	zw.code = "ZW"
	africa.nations.append(zw)
	zw.locales = [
		Locale.new("English", "en"),
		Locale.new("Shona", "sn"),
		Locale.new("Northern Ndebele", "nd")
	]
	zw.borders = [
		"BW", "MZ", "ZA", "ZM"
	]

	# Singapore
	var sg : Nation = Nation.new()
	sg.name = tr("Singapore")
	sg.code = "SG"
	asia.nations.append(sg)
	sg.locales = [
		Locale.new("English", "en"),
		Locale.new("Malay", "ms"),
		Locale.new("Tamil", "ta"),
		Locale.new("Chinese", "zh")
	]

	# Slovakia
	var sk : Nation = Nation.new()
	sk.name = tr("Slovakia")
	sk.code = "SK"
	europe.nations.append(sk)
	sk.locales = [
		Locale.new("Slovak", "sk")
	]
	sk.borders = [
		"AT", "CZ", "HU", "PL", "UA"
	]

	# Slovenia
	var si : Nation = Nation.new()
	si.name = tr("Slovenia")
	si.code = "SI"
	europe.nations.append(si)
	si.locales = [
		Locale.new("Slovene", "sl")
	]
	si.borders = [
		"AT", "HR", "IT", "HU"
	]

	# Somalia
	var so : Nation = Nation.new()
	so.name = tr("Somalia")
	so.code = "SO"
	africa.nations.append(so)
	so.locales = [
		Locale.new("Somali", "so"),
		Locale.new("Arabic", "ar")
	]
	so.borders = [
		"DJ", "ET", "KE"
	]

	# Spain
	var es : Nation = Nation.new()
	es.name = tr("Spain")
	es.code = "ES"
	europe.nations.append(es)
	es.locales = [
		Locale.new("Spanish", "es")
	]
	es.borders = [
		"AD", "FR", "GI", "PT", "MA"
	]

	# Sri Lanka
	var lk : Nation = Nation.new()
	lk.name = tr("Sri Lanka")
	lk.code = "LK"
	asia.nations.append(lk)
	lk.locales = [
		Locale.new("Sinhalese", "si"),
		Locale.new("Tamil", "ta")
	]
	lk.borders = [
		"IN"
	]

	# Saint Kitts and Nevis
	var kn : Nation = Nation.new()
	kn.name = tr("Saint Kitts and Nevis")
	kn.code = "KN"
	north_america.nations.append(kn)
	kn.locales = [
		Locale.new("English", "en")
	]

	# Saint Lucia
	var lc : Nation = Nation.new()
	lc.name = tr("Saint Lucia")
	lc.code = "LC"
	north_america.nations.append(lc)
	lc.locales = [
		Locale.new("English", "en")
	]

	# Saint Vincent and the Grenadines
	var vc : Nation = Nation.new()
	vc.name = tr("Saint Vincent and the Grenadines")
	vc.code = "VC"
	north_america.nations.append(vc)
	vc.locales = [
		Locale.new("English", "en")
	]

	# South Africa
	var za : Nation = Nation.new()
	za.name = tr("South Africa")
	za.code = "ZA"
	africa.nations.append(za)
	za.locales = [
		Locale.new("Afrikaans", "af"),
		Locale.new("English", "en"),
		Locale.new("Southern Ndebele", "nr"),
		Locale.new("Southern Sotho", "st"),
		Locale.new("Swati", "ss"),
		Locale.new("Tswana", "tn"),
		Locale.new("Tsonga", "ts"),
		Locale.new("Venda", "ve"),
		Locale.new("Xhosa", "xh"),
		Locale.new("Zulu", "zu")
	]
	za.borders = [
		"BW", "LS", "MZ", "NA", "SZ", "ZW"
	]

	# Sudan
	var sd : Nation = Nation.new()
	sd.name = tr("Sudan")
	sd.code = "SD"
	africa.nations.append(sd)
	sd.locales = [
		Locale.new("Arabic", "ar"),
		Locale.new("English", "en")
	]
	sd.borders = [
		"CF", "TD", "EG", "ER", "ET", "LY", "SS"
	]

	# South Korea
	var kr : Nation = Nation.new()
	kr.name = tr("South Korea")
	kr.code = "KR"
	asia.nations.append(kr)
	kr.locales = [
		Locale.new("Korean", "ko")
	]
	kr.borders = [
		"KP"
	]

	# South Sudan
	var ss : Nation = Nation.new()
	ss.name = tr("South Sudan")
	ss.code = "SS"
	africa.nations.append(ss)
	ss.locales = [
		Locale.new("English", "en")
	]
	ss.borders = [
		"CF", "CD", "ET", "KE", "SD", "UG"
	]

	# Suriname
	var sr : Nation = Nation.new()
	sr.name = tr("Suriname")
	sr.code = "SR"
	south_america.nations.append(sr)
	sr.locales = [
		Locale.new("Dutch", "nl")
	]
	sr.borders = [
		"BR", "GF", "GY"
	]

	# Syria
	var sy : Nation = Nation.new()
	sy.name = tr("Syria")
	sy.code = "SY"
	asia.nations.append(sy)
	sy.locales = [
		Locale.new("Arabic", "ar")
	]
	sy.borders = [
		"IQ", "IL", "JO", "LB", "TR"
	]

	# Tajikistan
	var tj : Nation = Nation.new()
	tj.name = tr("Tajikistan")
	tj.code = "TJ"
	asia.nations.append(tj)
	tj.locales = [
		Locale.new("Tajik", "tg"),
		Locale.new("Russian", "ru")
	]
	tj.borders = [
		"AF", "CN", "KG", "UZ"
	]

	# Taiwan
	var tw : Nation = Nation.new()
	tw.name = tr("Taiwan")
	tw.code = "TW"
	asia.nations.append(tw)
	tw.locales = [
		Locale.new("Chinese", "zh")
	]

	# Tanzania
	var tz : Nation = Nation.new()
	tz.name = tr("Tanzania")
	tz.code = "TZ"
	africa.nations.append(tz)
	tz.locales = [
		Locale.new("Swahili", "sw"),
		Locale.new("English", "en")
	]
	tz.borders = [
		"BI", "CD", "KE", "MW", "MZ", "RW", "UG", "ZM"
	]

	# Thailand
	var th : Nation = Nation.new()
	th.name = tr("Thailand")
	th.code = "TH"
	asia.nations.append(th)
	th.locales = [
		Locale.new("Thai", "th")
	]
	th.borders = [
		"MM", "KH", "LA", "MY"
	]

	# Togo
	var tg : Nation = Nation.new()
	tg.name = tr("Togo")
	tg.code = "TG"
	africa.nations.append(tg)
	tg.locales = [
		Locale.new("French", "fr")
	]
	tg.borders = [
		"BJ", "BF", "GH"
	]

	# Tonga
	var to : Nation = Nation.new()
	to.name = tr("Tonga")
	to.code = "TO"
	oceania.nations.append(to)
	to.locales = [
		Locale.new("English", "en"),
		Locale.new("Tonga (Tonga Islands)", "to")
	]

	# Trinidad and Tobago
	var tt : Nation = Nation.new()
	tt.name = tr("Trinidad and Tobago")
	tt.code = "TT"
	north_america.nations.append(tt)
	tt.locales = [
		Locale.new("English", "en")
	]

	# Chad
	var td : Nation = Nation.new()
	td.name = tr("Chad")
	td.code = "TD"
	africa.nations.append(td)
	td.locales = [
		Locale.new("French", "fr"),
		Locale.new("Arabic", "ar")
	]
	td.borders = [
		"CM", "CF", "LY", "NE", "NG", "SD"
	]

	# Czech Republic
	var cz : Nation = Nation.new()
	cz.name = tr("Czech Republic")
	cz.code = "CZ"
	europe.nations.append(cz)
	cz.locales = [
		Locale.new("Czech", "cs"),
		Locale.new("Slovak", "sk")
	]
	cz.borders = [
		"AT", "DE", "PL", "SK"
	]

	# Tunisia
	var tn : Nation = Nation.new()
	tn.name = tr("Tunisia")
	tn.code = "TN"
	africa.nations.append(tn)
	tn.locales = [
		Locale.new("Arabic", "ar")
	]
	tn.borders = [
		"DZ", "LY"
	]

	# Turkey
	var tur : Nation = Nation.new()
	tur.name = tr("Turkey")
	tur.code = "TR"
	asia.nations.append(tur)
	tur.locales = [
		Locale.new("Turkish", "tr")
	]
	tur.borders = [
		"AM", "AZ", "BG", "GE", "GR", "IR", "IQ", "SY"
	]

	# Turkmenistan
	var tm : Nation = Nation.new()
	tm.name = tr("Turkmenistan")
	tm.code = "TM"
	asia.nations.append(tm)
	tm.locales = [
		Locale.new("Turkmen", "tk"),
		Locale.new("Russian", "ru")
	]
	tm.borders = [
		"AF", "IR", "KZ", "UZ"
	]

	# Tuvalu
	var tv : Nation = Nation.new()
	tv.name = tr("Tuvalu")
	tv.code = "TV"
	oceania.nations.append(tv)
	tv.locales = [
		Locale.new("English", "en")
	]

	# Uganda
	var ug : Nation = Nation.new()
	ug.name = tr("Uganda")
	ug.code = "UG"
	africa.nations.append(ug)
	ug.locales = [
		Locale.new("English", "en"),
		Locale.new("Swahili", "sw")
	]
	ug.borders = [
		"CD", "KE", "RW", "SS", "TZ"
	]

	# Ukraine
	var ua : Nation = Nation.new()
	ua.name = tr("Ukraine")
	ua.code = "UA"
	europe.nations.append(ua)
	ua.locales = [
		Locale.new("Ukrainian", "uk")
	]
	ua.borders = [
		"BY", "HU", "MD", "PL", "RO", "RU", "SK"
	]

	# Hungary
	var hu : Nation = Nation.new()
	hu.name = tr("Hungary")
	hu.code = "HU"
	europe.nations.append(hu)
	hu.locales = [
		Locale.new("Hungarian", "hu")
	]
	hu.borders = [
		"AT", "HR", "RO", "RS", "SK", "SI", "UA"
	]

	# Uruguay
	var uy : Nation = Nation.new()
	uy.name = tr("Uruguay")
	uy.code = "UY"
	south_america.nations.append(uy)
	uy.locales = [
		Locale.new("Spanish", "es")
	]
	uy.borders = [
		"AR", "BR"
	]

	# Uzbekistan
	var uz : Nation = Nation.new()
	uz.name = tr("Uzbekistan")
	uz.code = "UZ"
	asia.nations.append(uz)
	uz.locales = [
		Locale.new("Uzbek", "uz"),
		Locale.new("Russian", "ru")
	]
	uz.borders = [
		"AF", "KZ", "KG", "TJ", "TM"
	]

	# Vanuatu
	var vu : Nation = Nation.new()
	vu.name = tr("Vanuatu")
	vu.code = "VU"
	oceania.nations.append(vu)
	vu.locales = [
		Locale.new("Bislama", "bi"),
		Locale.new("English", "en"),
		Locale.new("French", "fr")
	]

	# Vatican City
	var va : Nation = Nation.new()
	va.name = tr("Vatican City")
	va.code = "VA"
	europe.nations.append(va)
	va.locales = [
		Locale.new("Latin", "la"),
		Locale.new("Italian", "it"),
		Locale.new("French", "fr"),
		Locale.new("German", "de")
	]
	va.borders = [
		"IT"
	]


	# Venezuela
	var ve : Nation = Nation.new()
	ve.name = tr("Venezuela")
	ve.code = "VE"
	south_america.nations.append(ve)
	ve.locales = [
		Locale.new("Spanish", "es")
	]
	ve.borders = [
		"BR", "CO", "GY"
	]

	# United Arab Emirates
	var ae : Nation = Nation.new()
	ae.name = tr("United Arab Emirates")
	ae.code = "AE"
	asia.nations.append(ae)
	ae.locales = [
		Locale.new("Arabic", "ar")
	]
	ae.borders = [
		"OM", "SA"
	]

	# United States of America
	var us : Nation = Nation.new()
	us.name = tr("United States of America")
	us.code = "US"
	north_america.nations.append(us)
	us.locales = [
		Locale.new("English", "en")
	]
	us.borders = [
		"CA", "MX"
	]

	# United Kingdom
	var gb : Nation = Nation.new()
	gb.name = tr("United Kingdom")
	gb.code = "GB"
	europe.nations.append(gb)
	gb.locales = [
		Locale.new("English", "en")
	]
	gb.borders = [
		"IE"
	]

	# Vietnam
	var vn : Nation = Nation.new()
	vn.name = tr("Vietnam")
	vn.code = "VN"
	asia.nations.append(vn)
	vn.locales = [
		Locale.new("Vietnamese", "vi")
	]
	vn.borders = [
		"KH", "CN", "LA"
	]

	# Central African Republic
	var cf : Nation = Nation.new()
	cf.name = tr("Central African Republic")
	cf.code = "CF"
	africa.nations.append(cf)
	cf.locales = [
		Locale.new("French", "fr"),
		Locale.new("Sango", "sg")
	]
	cf.borders = [
		"CM", "TD", "CD", "CG", "SS", "SD"
	]

	# Cyprus
	var cy : Nation = Nation.new()
	cy.name = tr("Cyprus")
	cy.code = "CY"
	asia.nations.append(cy)
	cy.locales = [
		Locale.new("Greek", "el"),
		Locale.new("Turkish", "tr"),
		Locale.new("Armenian", "hy")
	]

	# sort continents alphabetically
	world.continents.sort_custom(func(a: Continent, b: Continent) -> bool:
		return a.name < b.name)

	# sort nations alphabetically
	for continent: Continent in world.continents:
		continent.nations.sort_custom(func(a: Nation, b: Nation) -> bool:
			return a.name < b.name)

	return world
