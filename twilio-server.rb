require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'
#require 'httpclient' => sinatra require does not lke this require for some reason... find out why (need this for redirects)
#require 'uri'
#require 'rubygems'

set :port, 4567
set :c, 0

###get list of urls from csv file

url_list = ["https://calltrackdata.com/webreports/audio.jsp?callID=2086701093&authentication=75E0E52C2F022233FC3070FC979C7E33",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086725818&authentication=21C006EED2356B4A1D796F0DE957C6DA",
"https://calltrackdata.com/webreports/audio.jsp?callID=44609277&authentication=5D46E05C2DF139E6C4C47F16206287C1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086781467&authentication=E83484B24EC788F446EABC7F6B4049A0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086796602&authentication=3B37BCD861F88B4F8D4366E3004370B5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087158414&authentication=F0393BAF94E6C88560B814F8646963C8",
"https://calltrackdata.com/webreports/audio.jsp?callID=44826902&authentication=200DFD9505C04A4DB9A755AEB4099881",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087761316&authentication=FD67388B4061CDB9780855ED0C3F65C5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087822193&authentication=4433268F5253F6058B45625E035BF3CD",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087908331&authentication=22F323842B97537F4788778DD0965EEF",
"https://calltrackdata.com/webreports/audio.jsp?callID=44937390&authentication=A3CDF7EB38E05125CF661CD1175AB612",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087947914&authentication=FEF17D50AD9C1F018D1A4FD7CF2ED118",
"https://calltrackdata.com/webreports/audio.jsp?callID=44974283&authentication=56BAF407F32260B40C34E7D7A16A50F1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088120861&authentication=5B1FBC68EF808ACEDCA419B1CB7DB83F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088167318&authentication=9B26D8756D8F4747DA3B65C2C69F5BEC",
"https://calltrackdata.com/webreports/audio.jsp?callID=45002459&authentication=835383DCB43EBDDF8A67E0C7E96EC482",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088256667&authentication=9A58FCB4E728D3DB64EEF238D42CA611",
"https://calltrackdata.com/webreports/audio.jsp?callID=45018651&authentication=006013945FF2B8A968C48B6D424CFC0D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088284009&authentication=B9BEA4453706DDFCCE12EA0E5783B709",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088416757&authentication=35D4C4278180739EC8A3850D815ED16C",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088425801&authentication=6C60F4041FC526C1558761C69ED4F0B5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088434866&authentication=4AF1162044037760A92BB1BE80A86238",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088461854&authentication=5E4A9CDE4843A3537C7E94F54FEEB1C3",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088487978&authentication=CF33EE313B63AA51478E0FDA8D61B26E",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088599710&authentication=E49FD501A711B518935048C47F0D59F2",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088681896&authentication=BCB8AD7AC66C6C7C67695E21D039C828",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088853938&authentication=B726E9AB2F5E3C4AFA8C4AA440788DC7",
"https://calltrackdata.com/webreports/audio.jsp?callID=45197428&authentication=B0B835D69C079342042B4DA959DCB993",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089008452&authentication=08A810DFCEC60B46827651740E15347F",
"https://calltrackdata.com/webreports/audio.jsp?callID=45255110&authentication=60A292E1962EC4B341735649BBA336B0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089139323&authentication=059E123BB7890EE0AD7C29EB833B87F8",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089174253&authentication=F523864A44F10BDC11DC2020E4B2D4C7",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089344931&authentication=F532DC189E4E5450D61F924F43C88007",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089350609&authentication=FE69C33C8BA7AC4301C772C4EB3CEE57",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089463079&authentication=116239F820E5EB0F6BFC1D3E3075E160",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089659745&authentication=2B929639506180A60D2513FE4E3B84D7",
"http://reporting.callsource.com/webreports/audio.jsp?callID=45476462&mailboxID=2859980&authentication=null",
"https://calltrackdata.com/webreports/audio.jsp?callID=2089894792&authentication=1E188B273DED6D4BACF4DDC7D9C17A9D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090048941&authentication=F7C9FAD919014D8AB42BDB45A72FEA25",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090118851&authentication=2CFC46E51C649F106094C4800BB0C780",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090188061&authentication=FD30729DBB0BD2F8F5E5A86693D2E21D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090203099&authentication=2BAB9FDAC727F673E6D7FA4EB632A9CC",
"https://calltrackdata.com/webreports/audio.jsp?callID=45597517&authentication=AAC8ACE9488806B95833856F2C7C6B02",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090363169&authentication=403611553A9D67BBA81EFD43BCE34BD4",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090389831&authentication=7EF926FF74C3534EC57F8A75315B8396",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090563741&authentication=2F6B1F061CFB694D069C5ABD420A8E96",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090564405&authentication=4DD411B798E4CEB16B903C17B895E5D2",
"https://calltrackdata.com/webreports/audio.jsp?callID=2090678058&authentication=94295DB3A6D9492BF7EDD5B458B950E3",
"https://calltrackdata.com/webreports/audio.jsp?callID=45769259&authentication=C50AD1E6570E23B2262F2CFC4937B515",
"https://calltrackdata.com/webreports/audio.jsp?callID=45837122&authentication=2785E0804F9C07C3CC1AD8CDFEE4F0B6",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091206709&authentication=44C74738A43EF59333CD1EF0C1F8388A",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091216221&authentication=80A11525FBD071F010EF19CA5397541E",
"https://calltrackdata.com/webreports/audio.jsp?callID=45866164&authentication=4C8B19EF50E70ACE906F76C457A767F5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091284067&authentication=84F36C1A3B666206C0D2BE923A07E87D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091298806&authentication=729331BDBFF4416A2EBADC44CDD3033A",
"https://calltrackdata.com/webreports/audio.jsp?callID=45911664&authentication=3A4A05234466B04676558EE4B03CD972",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091539640&authentication=196B96A4A1AFA7AC0CC5F1060B93A250",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091574549&authentication=F94735C45007744BBD37C748D5CC8BFD",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091575258&authentication=4B3FDD9D6D2456988931FBBCBD68AEE1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091576203&authentication=E959C235843468CA3AF83041F70A9A76",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091653754&authentication=E4DE179D2DD7D1D029CAB7462B305B59",
"https://calltrackdata.com/webreports/audio.jsp?callID=45990571&authentication=F3A9644250F1F5A375F656C0A3C370E7",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091686537&authentication=935DEA63D40FDEFBE0DE712C83BF5767",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091724035&authentication=24FEFFA45C3EC93146FCC22E954600B3",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091818323&authentication=FF93676DADBC7F887D66D1F0379A9A9E",
"https://calltrackdata.com/webreports/audio.jsp?callID=46041666&authentication=DD9139B0786183AAF19344378360F0FD",
"https://calltrackdata.com/webreports/audio.jsp?callID=46044207&authentication=B725A752EF45AC320F3C20C058D076F4",
"https://calltrackdata.com/webreports/audio.jsp?callID=46046480&authentication=326EF781B098620DD640580C0465A032",
"https://calltrackdata.com/webreports/audio.jsp?callID=2091862683&authentication=6ADE44707AA7052FF1AC30E4027787D4",
"https://calltrackdata.com/webreports/audio.jsp?callID=46053127&authentication=76198C8D557BD9964B2DAC95C257B7C1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092041948&authentication=41D5EB426F8C641710369BDE415DD656",
"https://calltrackdata.com/webreports/audio.jsp?callID=46101516&authentication=B96CC11DD3F5399496F709AE548E8EBE",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092083116&authentication=D93DC15796AC7C339BAC96A492FF732A",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092084572&authentication=9F2CDFFCAF6DE6405C233C393CB886EF",
"https://calltrackdata.com/webreports/audio.jsp?callID=46112923&authentication=6296E9D13A27B332CEA29BE80EC40608",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092103354&authentication=02954D4E6B4556A9C7A76B6F686F63F0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092133281&authentication=403BF5F799AD7EC8225A5B6817D32511",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092168933&authentication=A1FC95FBCB247EC248B68736C67EAC94",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092240335&authentication=0507E9B634B7CE0173535CF25A9EF1CE",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092245898&authentication=24CFDF241A2AA240A54B40FA4084D2E2",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092261962&authentication=E897ABCC0F9F25FDBB09458C6BEE6972",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092353299&authentication=83BE7D1C75699F8DC60A597616EEEC47",
"https://calltrackdata.com/webreports/audio.jsp?callID=46202450&authentication=EBC25FF0CFE9003DE9F941F4AC4F942F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092428511&authentication=FCD9B941CAA1EC45F6FEFE10C2C8617A",
"https://calltrackdata.com/webreports/audio.jsp?callID=46215815&authentication=13D532D4CDF3BB5B3F021CD6943D2A83",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092508831&authentication=2471E3C7DE3CBA571BA88CC9FD307586",
"https://calltrackdata.com/webreports/audio.jsp?callID=46296859&authentication=62E327BBF21708EDE51A4E7F04C3699C",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092770651&authentication=D54E40128B83782511F19516D64EBC21",
"https://calltrackdata.com/webreports/audio.jsp?callID=46301973&authentication=09F0D46BD270F86F4E8A7684972815A9",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092798443&authentication=9E7DE14C34760770D1D808C74F0F8801",
"https://calltrackdata.com/webreports/audio.jsp?callID=46315001&authentication=C693073C1BE6A2D6FBCB9DFCD5B8E2AA",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092872339&authentication=6AB7C801B095706E0668E56A27CDEB0D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092877759&authentication=1A146E4B29223B36C93247B6D7DA38CB",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092948044&authentication=2D0A9040ADCBDDE8A940ED807C91AD8C",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092979318&authentication=CE03DD370CE59D7A760A3F518FD74051",
"https://calltrackdata.com/webreports/audio.jsp?callID=2092992448&authentication=B974BB4250072E2AFCB9640D8C53A55F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093017205&authentication=8BC0A99B7373E39AF70CA9515D64BEC7",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093061387&authentication=A502D4C110BC942672EC74CBED63A858",
"https://calltrackdata.com/webreports/audio.jsp?callID=46382709&authentication=13E58646D47CFC21429A488EA8FC2DA3",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093251704&authentication=BE6203DD7635D45E2E56689AC9C8E6D0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093415622&authentication=7C5192549F61568F7E04F6DA2DED0F82",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093431259&authentication=B7E4A2005CA5D58DA48A37549D490EEB",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093446705&authentication=6BDCACBA3E6147F6AC2F744E82AA9F2A",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093447128&authentication=1B5A8BF10D932DCC5BEE1D111D496B6D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093449848&authentication=B8E02F2569D0C3129E4C9A7C14A24553",
"https://calltrackdata.com/webreports/audio.jsp?callID=46485326&authentication=C421FD59DB9B23CD515CE66A2EE092DF",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093541235&authentication=56A2B63C1ADE7D1C0B876AF50C6BC97F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093547337&authentication=AED9B9FFB88060277E226BC4CD451290",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093548989&authentication=7948CF21B5F0642AC418A92B1EE6CB73",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093552723&authentication=00498DC64E16D770BDB3CB380B325707",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093562431&authentication=46AC18A5AD49A7B3AFC483A43027EBEB",
"https://calltrackdata.com/webreports/audio.jsp?callID=2093842744&authentication=6AAACEA6CB0E185508AFF4A248DF79DD",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094058864&authentication=35E3971CFEF8BEBA348F9BF34CCAEA6F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094069818&authentication=7E201A06C18CF73C3CD9A1870BB6E8A8",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094176172&authentication=C5C6D3E2C7EE10DA633D01D82FA9E292",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094223907&authentication=00AEA2EFC65C75FFA971CD526EC44D2C",
"https://calltrackdata.com/webreports/audio.jsp?callID=46776789&authentication=DAFB659D5189AE09FAB9703C2BF16010",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094513457&authentication=0A8F44BCCD021254A0EABA4291552E77",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094544847&authentication=3C8407962D8292A3CD74124D54E4158C",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094545096&authentication=9379332DE9CB48185C05ACAC41A2C3AD",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094563058&authentication=6A219318476B94BD7921C40FE897E228",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094592446&authentication=D9BEEEE2E405A1A7285A547E9ED8B9C5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094603017&authentication=EAF2EE47614E4FCE737D6817925DD5E8",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094696256&authentication=263A43E1479ACF58256740294B7C8D4F",
"https://calltrackdata.com/webreports/audio.jsp?callID=46836826&authentication=6F337FFDBBAC2C3B7D398185DA6775B2",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094713990&authentication=A71F0155197537F716CABA58382F8EFF",
"https://calltrackdata.com/webreports/audio.jsp?callID=46846524&authentication=F8F42F79CF5C6E9586B0E760BA5D6359",
"https://calltrackdata.com/webreports/audio.jsp?callID=2094757533&authentication=81ABF57B0C8D5DDBF4FB8781F0286A7C",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095006303&authentication=C7B2D8EBD5552C32B8D434561529F345",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095051031&authentication=5157C1D838263449E5FA4B1E29A7DFDD",
"https://calltrackdata.com/webreports/audio.jsp?callID=46953695&authentication=18AF39D863B3E34CE35286CB9EAD83C1",
"https://calltrackdata.com/webreports/audio.jsp?callID=46953838&authentication=BB2C932438C9E05B8DB3DF0EC9A765DF",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095133605&authentication=4F3BF809F0DE36C2CE29A112D5127D12",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095159805&authentication=DA88B6B5A00C8427770425A75AA2B0DF",
"https://calltrackdata.com/webreports/audio.jsp?callID=46969449&authentication=CC0328AD641683477BEA860832891A86",
"https://calltrackdata.com/webreports/audio.jsp?callID=46974579&authentication=FF8233E025C82B897D9968914095D664",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095210209&authentication=F2F1B9EDB29F4C693627D8B06422CA31",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095254904&authentication=BB3F626C0D11FA37E7845770013E8A87",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095255029&authentication=BAFFE2819F8A0F319C734EC74AD824F8",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095262173&authentication=E63D20AD82986805473C5C7F0C9B3BAE",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095285491&authentication=B0491027FD7FAE4C23B617A7FC424BBD",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095386918&authentication=CD39B1D551E4655030F8AF42613FDE59",
"https://calltrackdata.com/webreports/audio.jsp?callID=47050556&authentication=FFEB352F51B5BC3348B97D117D11CDEC",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095493384&authentication=EADD0A4721121E75CF399EB9FFC1288E",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095537888&authentication=FCC377517DF27D55726D620638576F19",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095539952&authentication=A5B46E26026111746AC38BAAFC27E52D",
"https://calltrackdata.com/webreports/audio.jsp?callID=47075407&authentication=2B8E22E188BAAD45F1453152FD9AB865",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095565259&authentication=8D134C24DAD5BB94790FCD0A30A1C449",
"https://calltrackdata.com/webreports/audio.jsp?callID=47082118&authentication=53B1069A3181B4199EE62BC4CB4FAEE8",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095711958&authentication=B50A8302F6CB6246DA3B3953A5751876",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095739454&authentication=0F3B0059432996F51FC9A2441596C97F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095744154&authentication=25548048FEE41AAD2E3B2606FB3170E0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095755247&authentication=27B6A240297C8E88AC6C31BBC3C9C228",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095761981&authentication=F25EC6859A790698FB008B57AEEFCB1B",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095795713&authentication=4F3ABC66E392C1AD6E9B2F14083166F4",
"https://calltrackdata.com/webreports/audio.jsp?callID=2095814105&authentication=C20B828D593A2AE227D0F375FB223191",
"https://calltrackdata.com/webreports/audio.jsp?callID=47194464&authentication=618B9848D8DA8878268051F6B1B04DCF",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096021211&authentication=2C105FAB7619FBE5C7E975EBE8AC5152",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096072585&authentication=A766585D58E3A3FF68942F19A711AFAF",
"https://calltrackdata.com/webreports/audio.jsp?callID=47277886&authentication=5FB087DB782290F8E65A09F6FB5C49D9",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096289235&authentication=4BDA8A58B671ACAD0B986DA888A7601D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096384515&authentication=9DA05D26EBB9D6D6E8F23584B2F431FA",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096430982&authentication=47EFCFFCA12A3E99B666CA150E4048D7",
"https://calltrackdata.com/webreports/audio.jsp?callID=47346539&authentication=77A7E4A46A6431E71458E116630E791D",
"https://calltrackdata.com/webreports/audio.jsp?callID=47353430&authentication=1EF4C61516255A5ED270700527758C83",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096556390&authentication=14BF13059791B54C898547B658E8B164",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096563718&authentication=A67CC0ACFA32C4768F6F67C0CF690B74",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096683739&authentication=8AC8D8986D91F35E29A9D9494D6166DD",
"https://calltrackdata.com/webreports/audio.jsp?callID=47406152&authentication=6717A702B2C23DA19CD629035A9DFDC7",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096733412&authentication=FA19DF1548727DBB3BB9CF6844D22848",
"https://calltrackdata.com/webreports/audio.jsp?callID=47429882&authentication=99E0DD64756E4C56E99F300F05A59A88",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096869951&authentication=83277A9A72A8F8210394B6746087C9F6",
"https://calltrackdata.com/webreports/audio.jsp?callID=2096936803&authentication=FD35929E2DD517C0A751E70A0DD18173",
"http://reporting.callsource.com/webreports/audio.jsp?callID=2097027528&mailboxID=1180175&authentication=EA166A87899D75C742937B657614174F",
"http://reporting.callsource.com/webreports/audio.jsp?callID=47503848&mailboxID=2687256&authentication=E18C7D46D9AC91903CA089DCBBA779D5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097297599&authentication=8C847E69F61B15E975EEAFBFF6BB4F04",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097325188&authentication=6F496534DA41387FCA156FC35A50281B",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097331632&authentication=093966A355087067203D53A16E65086A",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097422683&authentication=9CC6CB1913EF8F7228405B8C8BDA35E3",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097496001&authentication=FD308C32306FC5081963A1CFC333EBB2",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097496607&authentication=15B5DF14F8389AA6A62411BA2899B734",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097496693&authentication=A837C06395FEA24397C3E4ACB884C4BC",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097522078&authentication=F35C7A18B585CB07A59706A8F0B0F7C4",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097557125&authentication=6DDA30098F42EFAD91A6D13888649D9D",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097595039&authentication=C090B7BBC9CEB107DA8532D5A6572C05",
"https://calltrackdata.com/webreports/audio.jsp?callID=47678680&authentication=59ADB73D185188E2DE5357DE1479F532",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097893844&authentication=FA93A443BA93FFC24489BFA842A0AB87",
"http://reporting.callsource.com/webreports/audio.jsp?callID=47844074&mailboxID=2594909&authentication=002A0E2E208FB4E8A1E73C7FCF142261",
"https://calltrackdata.com/webreports/audio.jsp?callID=47851623&authentication=E3853691B6D8C31C9172B243FB56DEFB",
"https://calltrackdata.com/webreports/audio.jsp?callID=2097934704&authentication=7A3B1D14DB762A19D065D7B0F5F82A89",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098006030&authentication=33EE2209BC685CBE91D217AA1052B25A",
"https://calltrackdata.com/webreports/audio.jsp?callID=47921154&authentication=6E74100CFE6833414AC67F6FB96E0E81",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098037955&authentication=1E03AC2BECB2A30CD59BB5F34C13F65F",
"https://calltrackdata.com/webreports/audio.jsp?callID=48000898&authentication=E87FD0A4225D7F8361C87043C14A04A9",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098171544&authentication=2EF20656A47F2C2B4695BC9BE086B4A4",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098180534&authentication=696CE7E82EF6CEE3FBEB3B4BE6670C94",
"https://calltrackdata.com/webreports/audio.jsp?callID=48061916&authentication=AFD925206A998481D97FEF279DB0722B",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098304943&authentication=846A3404E79E548F11836AF8E37CFF54",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098315823&authentication=70D3BDBB0CAF4A7864525A5C6AAD2C92",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098421418&authentication=0FCCF81726FE7B3D0D61A397263619B0",
"https://calltrackdata.com/webreports/audio.jsp?callID=48107823&authentication=11FD0F5258872B1E20279AF00A464684",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098613009&authentication=C76B190695F7141D22C01D4F538C3338",
"https://calltrackdata.com/webreports/audio.jsp?callID=48263784&authentication=74FDEF6D61D8D28A3D536233EEBAF4CB"]

set :urls, []
url_count = settings.urls.count
###check url for redirects

def getredirectedurls(url_list)
	url_list.each do |url|
		result = Curl::Easy.perform(url) do |curl| 
		  curl.headers["User-Agent"] = "..."
		  curl.verbose = false
		  curl.follow_location = true
		end
		settings.urls.push = result.last_effective_url
	end
end

getrediredtedurls(url_list)


get '/' do
  "work! #{url_count}"
end
###sinatra get request handling

# get %r{/.*} do
# 	pass if request.path_info == "/favicon.ico"
# 	pass if settings.c >= url_count
# 	"#{urls[settings.c]}"
# 	Twilio::TwiML::Response.new do |r|
# 	    r.Say getredirectedurl(urls[settings.c])
# 	end.text
# end

# get %r{/.*} do
# 	pass if request.path_info == "/favicon.ico"
# 	pass if settings.c < url_count
# 	"no more files!"
# end

# after do
# 	if settings.c < url_count && request.path_info != "/favicon.ico"
# 		settings.c += 1
# 		puts "sending file #{settings.c} of #{url_count}"
# 	else
# 		puts "no files to send!"
# 	end
# end
