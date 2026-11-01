--// KBBI Word Finder GUI
--// Premium Look + Smooth Animated Toggle

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

if getgenv().KBBIGUI then
	pcall(function() getgenv().KBBIGUI:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KBBIGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")
getgenv().KBBIGUI = ScreenGui

-- ======================
-- DAFTAR KATA KBBI (huruf A)
-- ======================
local kbbiWords = {
-- KATA HURUF A
  "a", "aa", "aal", "aan", "aau", "ab", "aba", "abab", "abad", "abadi", "abadiah", "abadiat", "abah", "abai", "abaian", "abaka", "abakus", "abal", "abam", "aban",
	"abang", "abangan", "abangda", "abar", "abaran", "abas", "abau", "abaya", "abdas", "abdi", "abdikasi", "abdomen", "abdominal", "abdu", "abduksi", "abduktor", "abdul", "abece", "aben", "aberasi",
	"abian", "abid", "abidin", "abilah", "abimana", "abing", "abiogenesis", "abiosfer", "abiotik", "abis", "abisal", "abiseka", "abiturien", "abjad", "abjadiah", "ablasi", "ablaut", "ablepsia", "ablur", "abnormal",
	"abnormalitas", "abnus", "abolisi", "abon", "abonemen", "aborsi", "abortif", "abortus", "abrak", "abrakadabra", "abras", "abrasi", "abreaksi", "abreviasi", "abrikos", "abrupsi", "absah", "absen", "absensi", "absente",
	"absenteisme", "abses", "absis", "absolusi", "absolut", "absolutisme", "absorpsi", "abstinensi", "abstrak", "abstraksi", "absurd", "absurdisme", "abu", "abuan", "abuh", "abuk", "abul", "abulia", "abus", "acala",
	"acang", "acar", "acaram", "acat", "acatan", "acawi", "aceh", "acerang", "acik", "aco", "acu", "acuan", "acum", "acung", "ada", "adad", "adagium", "adalah", "adalat", "adam",
	"adan", "adang", "adap", "adaptabel", "adaptabilitas", "adaptasi", "adaptif", "adaptometer", "adaptor", "adapun", "adar", "adas", "adat", "adekuat", "adem", "adendum", "adenoid", "adenoma", "adhesi", "adhesif",
	"adiabatik", "adib", "adibusana", "adidaya", "adigang", "adiguna", "adika", "adikara", "adikarya", "adikodrati", "adiksi", "adiktif", "adikuasa", "adil", "adiluhung", "adimarga", "adinamia", "adinda", "adipati", "adiposa",
	"adipositas", "adiraja", "adiratna", "adisi", "adisional", "aditif", "adiwangsa", "adiwarna", "adjektif", "adjektiva", "administrasi", "administratif", "administrator", "admiral", "admisi", "adolesens", "adopsi", "adoptif", "adu", "aduan",
	"aduksi", "aduktor", "adveksi", "adventisia", "adverbia", "adverbial", "advertensi", "advis", "advokasi", "advokat", "aerasi", "aerob", "aerobik", "aerodinamika", "aerofobia", "aeronautika", "aerosol", "aerostatik", "afdal", "afeksi",
	"afektif", "afidavit", "afiks", "afiliasi", "afinitas", "afirmasi", "afirmatif", "afonia", "aforisme", "afrodisiak", "afsun", "afwah", "aga", "agah", "agak", "agal", "agam", "agama", "agamis", "agamawan",
	"agape", "agar", "agas", "agen", "agenda", "agensi", "ager", "agih", "agil", "agio", "agitasi", "agitatif", "agitator", "aglomerasi", "aglutinasi", "agnat", "agnosia", "agnostik", "agon", "agoni",
	"agonis", "agorafobia", "agraria", "agregat", "agresif", "agresi", "agresivitas", "agresor", "agrikultur", "agronomi", "agrostologi", "agrowisata", "aguk", "agul", "agun", "agunan", "agung", "agus", "Agustus", "ahad",
	"ahadiat", "ahimsa", "ahistoris", "ahkam", "ahli", "ahlulbait", "ahlulkitab", "ahlusunah", "ahmad", "ahmak", "ahorn", "ahwa", "aib", "airmata", "ajaib", "ajal", "ajar", "ajek", "ajengan", "aji",
	"ajir", "aju", "ajuk", "ajun", "akad", "akademi", "akademik", "akademikus", "akademis", "akal", "akan", "akar", "akasia", "akbar", "akidah", "akibat", "akik", "akikah", "akil", "akhir",
	"akhirat", "akhlak", "aklamasi", "aklimatisasi", "akomodasi", "akomodatif", "akordeon", "akrab", "akreditasi", "akrilik", "akrobat", "akrobatik", "akronim", "aksara", "akselerasi", "akselerator", "aksen", "aksentuasi", "aksep", "akseptabel",
	"akseptor", "akses", "aksesibel", "aksesibilitas", "aksesori", "aksi", "aksial", "aksidental", "aksila", "aksioma", "aksiomatik", "aksis", "akson", "akta", "aktif", "aktivis", "aktivitas", "aktor", "aktris", "aktual",
	"aktualisasi", "aktualita", "aktuaria", "aktuaris", "aku", "akuades", "akuaduk", "akuakultur", "akuarium", "akuatik", "akuifer", "akul", "akulturasi", "akumulasi", "akumulator", "akun", "akuntabel", "akuntabilitas", "akuntan", "akuntansi",
	"akurat", "akurasi", "akustik", "akut", "alabaster", "alaf", "alah", "alai", "alaika", "alaihi", "alaim", "alakal", "alam", "alami", "alamiah", "alamat", "alamin", "alan", "alang", "alasan",
	"alat", "alau", "alban", "albedo", "albinisme", "albino", "album", "albumin", "alef", "alegori", "alegoris", "alel", "alergi", "alfabet", "alfabetis", "alga", "algebra", "algoritma", "alhasil", "ali",
	"alias", "alibi", "alien", "alienasi", "alif", "alih", "alim", "aliran", "alis", "alkali", "alkaloid", "alkimia", "alkisah", "alkitab", "alkohol", "alkoholisme", "alkuna", "allah", "allamah", "almarhum",
	"almari", "alokasi", "alokasia", "alomorf", "alon", "alot", "alpaka", "alpa", "alpukat", "altar", "alternasi", "alternatif", "alternator", "altimeter", "alto", "altruis", "altruisme", "altruistik", "aluminium", "alun",
	"alunan", "alur", "alusi", "aluvial", "alveolus", "am", "ama", "amal", "amalgama", "amalgamasi", "aman", "amanah", "amanat", "amandel", "amandemen", "amar", "amarah", "amat", "amatir", "ambah",
	"ambai", "ambang", "ambar", "ambasador", "ambil", "ambisi", "ambisius", "ambivalen", "amblas", "amboi", "ambrol", "ambruk", "ambulans", "ambulatori", "ambun", "ameba", "ameliorasi", "amen", "amendemen", "amfibi",
	"amfiteater", "amfoter", "amikal", "amin", "amina", "amino", "amnesia", "amnesti", "amnion", "amoral", "amorf", "amortisasi", "ampas", "ampere", "amperemeter", "amplas", "amplifikasi", "amplitudo", "amplop", "ampuh",
	"ampul", "amputasi", "amuk", "amunisi", "ana", "anabolisme", "anakan", "anakronisme", "anal", "analgetik", "analisa", "analisis", "analitik", "analitis", "analog", "analogi", "anarki", "anarkis", "anarkisme", "anatomi",
	"ancam", "ancaman", "andai", "andal", "andalan", "andam", "andil", "andong", "aneh", "aneka", "anekdot", "aneksasi", "anemia", "anemometer", "anergi", "anestesi", "anestetis", "anfora", "anggah", "anggar",
	"anggaran", "anggas", "angguk", "anggun", "anggota", "anggrek", "anggur", "angin", "angit", "angka", "angkah", "angkara", "angkasa", "angkasawan", "angkat", "angkatan", "angkel", "angker", "angket", "angkin",
	"angklung", "angkong", "angkring", "angkringan", "angku", "angkuh", "angkul", "angkup", "angkur", "angkus", "angkut", "angkutan", "anglap", "angler", "anglo", "anglung", "angon", "angonan", "angop", "angot",
	"angpau", "angsa", "angsana", "angsoka", "angsur", "angsuran", "aniaya", "animasi", "anime", "animis", "animo", "anion", "anjlok", "anjing", "anjung", "anjungan", "anjur", "anjuran", "anomali", "anonim",
	"anonimitas", "anorganik", "antagonis", "antagonisme", "antarkota", "antarnegara", "antarpulau", "antartika", "antasida", "antek", "antena", "anter", "antero", "antologi", "antonim", "antropologi", "antropolog", "antusias", "antusiasme", "antre",
	"anugerah", "anuitas", "anulir", "anut", "anutan", "anyam", "anyaman", "anyar", "anyelir", "anyir", "apa", "apabila", "apak", "apal", "apalagi", "apar", "aparat", "aparatur", "apartemen", "apati",
	"apatis", "ape", "apel", "apersepsi", "apetit", "api", "apik", "apikal", "apkir", "aplaus", "aplikasi", "aplikatif", "aplikator", "apnea", "apodosis", "apotek", "apoteker", "apresiasi", "apresiatif", "april",
	"apriori", "apron", "apung", "ara", "arab", "arafah", "arah", "arahan", "arak", "arakan", "aral", "aram", "arang", "aransemen", "ararut", "aras", "arasy", "arawah", "arbitrase", "arbitrer",
	"arboretum", "arca", "ardi", "are", "area", "arek", "aren", "arena", "areola", "arestasi", "argumen", "argumentasi", "argumentatif", "ari", "aria", "arif", "arifin", "arih", "arik", "aring",
	"ario", "aris", "arisan", "aristokrasi", "aristokrat", "aristokratis", "arit", "aritmetika", "arjuna", "arkade", "arkais", "arkaisme", "arkeologi", "arkeolog", "arketipe", "arkian", "arkum", "arkus", "arloji", "armada",
	"armatur", "aroma", "aromatik", "arpus", "arsenal", "arsip", "arsiparis", "arsir", "arsitek", "arsitektur", "arta", "arteria", "arteri", "artesis", "artifisial", "artikel", "artikulasi", "artilleri", "artis", "artistik",
	"arwah", "arwana", "arya", "as", "asa", "asabat", "asabiyah", "asad", "asah", "asahan", "asai", "asak", "asal", "asalan", "asali", "asalkan", "asam", "asaman", "asap", "asar",
	"asas", "asasi", "asbak", "asbes", "asbut", "ase", "aseh", "aseksual", "asem", "asematik", "asep", "aser", "aset", "asetat", "aseton", "asi", "asidosis", "asih", "asik", "asil",
	"asimetris", "asimilasi", "asimetri", "asin", "asing", "asisten", "asistensi", "asli", "asma", "asmaraloka", "aso", "asoi", "asongan", "asosiasi", "asosiatif", "aspek", "asper", "aspirasi", "aspiratif", "aspirator",
	"aspirin", "asprak", "asrama", "asri", "asrof", "astaga", "astagfirullah", "astana", "astatin", "aster", "asteroid", "astigmatisme", "astral", "astringen", "astrologi", "astronaut", "astronomi", "astronom", "asu", "asuh",
	"asuhan", "asumsi", "asupan", "asuransi", "aswad", "asyik", "asyura", "atak", "ataksia", "atal", "atas", "atasan", "atau", "atap", "atar", "atasnama", "atase", "atensi", "ateret", "atis",
	"atlas", "atlet", "atletik", "atma", "atmosfer", "atom", "atomisasi", "atraksi", "atraktif", "atri", "atribut", "atribusi", "atrisi", "atrofi", "atsar", "atung", "atur", "aturan", "atus", "aulia",
	"aula", "auman", "aung", "aur", "aura", "aurat", "aurora", "aus", "auskultasi", "autentik", "autentikasi", "autis", "autisme", "autobiografi", "autodidak", "autofokus", "autografi", "autokrasi", "autokton", "automasi",
	"otomotif", "autonomi", "autopsi", "autoritarian", "autotrof", "aviasi", "aviator", "avifauna", "avokad", "awa", "awal", "awalan", "awam", "awan", "awang", "awas", "awet", "awin", "awur", "ayah",
	"ayahanda", "ayak", "ayakan", "ayal", "ayam", "ayan", "ayanda", "ayat", "ayem", "ayeng", "ayo", "ayom", "ayu", "ayub", "ayun", "ayunan", "ayunda", "ayut", "azab", "azali",
	"azam", "azan", "azas", "azasi", "azimat", "azimut", "aziz", "azmat", "azuki"

--KATA HURUF B
  "ba", "baal", "bab", "baba", "babad", "babah", "babak", "babakan", "babal", "babar", "babaran", "babat", "babatan", "babe", "babi", "babon", "babu", "babun", "babur", "babut",
  "baca", "bacaan", "bacak", "bacar", "bacek", "bacem", "bacik", "bacin", "baco", "bacok", "bacot", "bacul", "bad", "bada", "badai", "badak", "badal", "badan", "badani", "badar",
  "badari", "badi", "badik", "badminton", "badut", "bagai", "bagaimana", "bagak", "bagal", "bagan", "bagasi", "bagi", "bagian", "bagus", "bahagia", "bahak", "bahan", "bahana", "bahang", "bahar",
  "bahari", "bahas", "bahasa", "bahaya", "bahenol", "baheula", "bahu", "baiduri", "baik", "bait", "baja", "bajak", "baji", "baju", "bak", "bakal", "bakat", "bakar", "bakau", "bakda",
  "bakhil", "baki", "bakik", "bakmi", "bakteri", "bakti", "baku", "bakul", "bal", "bala", "balai", "balap", "balas", "balik", "baling", "balok", "balon", "balong", "balsam", "balu",
  "baluh", "balui", "balun", "balung", "balur", "balut", "bambang", "bambu", "ban", "banci", "bandar", "bandara", "banding", "bandit", "bandul", "bandut", "bang", "bangga", "bangir", "bangkai",
  "bangkal", "bangkit", "bangku", "bangkuang", "banglas", "bangor", "bangpak", "bangsa", "bangsal", "bangsat", "bangsawan", "bangun", "baning", "banir", "banjar", "banjir", "bank", "bantah", "bantai", "bantal",
  "banteng", "banter", "banting", "bantu", "banyak", "banyol", "bapa", "bapak", "baptis", "bara", "barang", "barat", "bareng", "barel", "baris", "barisan", "barometer", "baru", "baruh", "barut",
  "basah", "basau", "basi", "basis", "basmi", "basuh", "bata", "batal", "batang", "batas", "baterai", "batik", "batil", "batin", "batok", "batu", "batuk", "bau", "baung", "baur",
  "bawa", "bawah", "bawal", "bawang", "bayam", "bayang", "bayar", "bayat", "bayem", "bayi", "bayonet", "bayu", "bea", "beban", "bebas", "beber", "beberan", "bebek", "beda", "bedah",
  "bedak", "bedil", "bedol", "beduk", "begal", "begar", "begini", "begitu", "bekal", "bekam", "bekas", "beku", "bekuk", "bel", "bela", "belah", "belai", "belaka", "belakang", "belalai",
  "belalang", "belanda", "belang", "belanja", "belas", "belati", "belau", "belebas", "beledu", "belek", "belenggu", "belengket", "belengkok", "belerang", "belerong", "belia", "belian", "belimbing", "belincong", "beling",
  "belit", "belitung", "belok", "belon", "belong", "belot", "belu", "beludak", "beludru", "beluk", "belukar", "belulang", "belun", "belut", "bena", "benah", "benak", "benalu", "benam",
  "benang", "benar", "bencah", "bencana", "benci", "benda", "bendahara", "bendahari", "bendawi", "bendera", "bendi", "bendul", "bendung", "benefaktif", "bengal", "bengas", "benggal", "benggala", "benggol", "bengis",
  "bengkak", "bengkang", "bengkar", "bengkarung", "bengkeng", "bengkok", "bengkong", "bengkos", "bengkuang", "bengkunang", "bengoh", "bengok", "bengong", "benguk", "bengul", "bengung", "beni", "benih", "bening", "bentak",
  "bentala", "bentan", "bentang", "benteng", "bentes", "bentet", "bentul", "bentur", "benua", "benum", "benyai", "benyek", "benyot", "beo", "berahi", "berai", "berak", "berakah", "beram", "berambang",
  "berambut", "beranda", "berandal", "berandang", "berang", "berangan", "berangas", "berangka", "berangkat", "berangsang", "berangus", "berani", "beranta", "berantas", "berapa", "beras", "berat", "berau", "berbakti", "berbareng",
  "berbaring", "berbatas", "berbatu", "berbaur", "berbekal", "berbelit", "berbenah", "berbenih", "berberas", "berbesi", "berbiak", "berbicara", "berbisa", "berbobot", "berbagi", "berbahagia", "berbahaya", "berbaik", "berbaju", "berbakat",
  "berbalas", "berbalik", "berbalut", "berbanjir", "berbantah", "berbantal", "berbanyak", "berbapak", "berbarang", "berbaris", "berbaru", "berbasah", "berbasuh", "berbata", "berbau", "berbawa", "berbayar", "berbeban", "berbebas", "berbekas",
  "berbelah", "berbelanja", "berbelas", "berbenar", "berbencana", "berbenda", "berbengkel", "berbenteng", "berbentur", "berberat", "berbudi", "berbunga", "berbunyi", "berburu", "berbusa", "berbutir", "bercak", "bercakap", "bercampur", "bercanda",
  "bercanggah", "bercantik", "bercat", "bercerai", "bercerita", "bercermin", "bercita", "berciuman", "berdaerah", "berdagang", "berdaging", "berdahulu", "berdakwah", "berdamai", "berdanau", "berdandan", "berdapat", "berdarah", "berdasar", "berdatang",
  "berdaya", "berdebar", "berdebat", "berdebu", "berdedikasi", "berdegup", "berdekat", "berdekorasi", "berdelik", "berdemam", "berdemokrasi", "berdendam", "berdengar", "berdenyut", "berderai", "berderet", "berdesain", "berdesir", "berdetak", "berdialog",
  "berdiam", "berdikari", "berdimensi", "berdisiplin", "berdoa", "berdodol", "berdomisili", "berdua", "berduel", "berduka", "berdulu", "berduyun", "berebut", "beredar", "beregistrasi", "bereksperimen", "berelastis", "berema", "berembus", "berempat",
  "berenang", "berencana", "berenergi", "berengsek", "berengut", "berenteng", "bereputasi", "bererot", "beres", "beresiko", "beret", "berevolusi", "bergabung", "bergairah", "berganda", "bergandeng", "bergandul", "berganti", "bergantian", "bergantung",
  "bergaul", "bergaya", "bergembira", "bergeming", "bergejolak", "bergelombang", "bergelut", "bergema", "bergengsi", "bergegas", "bergigi", "bergiliran", "bergizi", "bergolak", "bergolek", "bergotong", "bergoyang", "bergubal", "bergulat", "berguling",
  "bergulir", "bergumul", "berguna", "bergunung", "bergurau", "bergurat"

--KATA HURUF C
  "c", "ca", "caba", "cabai", "cabak", "cabang", "cabar", "cabau", "cabik", "cabir", "cabo", "cabuk", "cabul", "cabut", "caca", "cacah", "cacak", "cacap", "cacar", "cacat", "caci", "cacing", "cad", "cadai", "cadang", "cadangan", "cadar", "cadas", "cadel", "cadik", "cadok", "cagak", "cagar", "caguh", "cahaya", "cair", "cais", "cak", "cakah", "cakalang", "cakap", "cakar", "cakep", "cakil", "cakra", "cakram", "cakrawala", "cakup", "cal", "calak", "calang", "calar", "caleg", "calo", "calon", "caluk", "calung", "cam", "camat", "cambah", "cambang", "cambuk", "camil", "campak", "campin", "campur", "canai", "canang", "cancut", "canda", "candi", "candu", "cang", "cangah", "cangak", "cangam", "cangap", "cangga", "canggah", "canggai", "canggih", "canggung", "cangkang", "cangkat", "cangkau", "cangkel", "cangking", "cangkir", "cangkok", "cangkol", "cangkring", "cangkul", "cangkung", "cangut", "cantas", "cantel", "cantik", "canting", "cantol", "cantrik", "cantum", "cap", "capa", "capai", "capak", "capal", "capar", "capcai", "capek", "capel", "caping", "caplok", "capuk", "capung", "cara", "carak", "caraka", "caram", "carang", "cari", "carik", "caring", "caruk", "carut", "cas", "casciscus", "cat", "catat", "catek", "catu", "catuk", "catur", "catut", "caul", "caung", "cawan", "cawangan", "cawat", "cawi", "cawis", "caya", "cebak", "cebakan", "cebar", "cebik", "cebikas", "cebok", "cebol", "cebong", "cebur", "cecah", "cecak", "cecap", "cece", "cecer", "cedera", "cedok", "ceduk", "cegah", "cegak", "cegar", "cegat", "ceguk", "cek", "ceka", "cekah", "cekak", "cekal", "cekam", "cekap", "cekau", "cekcok", "cekek", "cekel", "ceker", "ceki", "cekih", "cekik", "cekil", "ceking", "cekit", "cekok", "ceku", "cekuh", "cekuk", "cekung", "cekup", "cekur", "cekut", "cela", "celah", "celak", "celaka", "celam", "celana", "celang", "celapak", "celar", "celas", "celek", "celek eh", "celemek", "celempong", "celeng", "celengan", "celep", "celepa", "celepik", "celepuk", "celi", "celik", "celing", "celis", "celomes", "celomok", "celonok", "celopar", "celoteh", "celuk", "celung", "celup", "celur", "celus", "celut", "cema", "cemar", "cemara", "cemas", "cemat", "cemberut", "cembul", "cembung", "cemburu", "cemeeh", "cemek", "cemekian", "cemeti", "cemetuk", "cemomot", "cemong", "cempa", "cempaka", "cempedak", "cempeng", "cempera", "cemperling", "cempiang", "cempol", "cempo", "cempur", "cempurung", "cenak", "cenangau", "cenangga", "cenangkas", "cenayang", "cencala", "cencaluk", "cencang", "cencaru", "cencawi", "cendala", "cendana", "cendawan", "cendekia", "cendera", "cenderawasih", "cendera", "cenderung", "cendok", "cendol", "ceng", "cengal", "cengang", "cengap", "cengar", "cengbeng", "cengeh", "cengeng", "cengges", "cenggong", "cengis", "cengkal", "cengkam", "cengkar", "cengkaruk", "cengkau", "cengkedi", "cengkek", "cengkel", "cengkeram", "cengkerama", "cengkerawak", "cengkerik", "cengki", "cengkih", "cengking", "cengkir", "cengkok", "cengkol", "cengkong", "cengkuk", "cengkung", "cengkur", "cengli", "cengung", "cengut", "centang", "centeng", "centet", "centil", "centong", "centrung", "cepak", "cepat", "cepek", "cepeng", "cepet", "ceplok", "ceplos", "cepu", "cepuk", "cera", "cerah", "cerai", "cerak", "ceramah", "cerana", "cerancang", "cerang", "cerap", "cerat", "cerau", "cerawat", "cerca", "cercah", "cercak", "cercap", "cerdas", "cerdik", "cere", "cerecek", "cerek", "ceremai", "cerewet", "cergas", "ceri", "ceria", "cericap", "cericau", "cericip", "ceriga", "cering", "ceriping", "cerita", "ceriwis", "cermai", "cermat", "cermin", "cerna", "ceroboh", "cerobong", "cerocok", "cerompong", "ceronggah", "ceropong", "ceroteh", "cerowok", "cerucuh", "cerucuk", "cerucup", "ceruh", "ceruk", "cerun", "cerup", "cerut", "cerutu", "cespleng", "cetai", "cetak", "cetakan", "cetar", "cetek", "ceteng", "ceteri", "cetera", "ceti", "cetok", "cetus", "cetusan", "ceuk", "ceuki", "ceurik", "cewek", "ci", "ciap", "ciar", "cibir", "cibuk", "cicik", "cicil", "cicip", "cicir", "cicit", "ciduk", "cigak", "cih", "ciik", "cik", "cika", "cikadas", "cikadong", "cikadu", "cikal", "cikar", "cikat", "cikeh", "ciki", "cikok", "ciku", "cikun", "cikut", "cilap", "cilawagi", "cili", "cilik", "ciling", "cilok", "cilukba", "cimplung", "cina", "cincang", "cincau", "cincin", "cincong", "cincu", "cinda", "cindai", "cindil", "cindur", "cing", "cingak", "cingam", "cingangah", "cingap", "cingbing", "cingcau", "cingcing", "cingge", "cingkat", "cingkau", "cingkeh", "cingkrang", "cingur", "cinta", "cintamani", "cinteng", "cintrong", "cip", "cipai", "cipan", "ciplak", "ciplukan", "cipok", "ciprat", "cipta", "cir", "circa", "circir", "ciri", "cirit", "cis", "cit", "cita", "citra", "citraan", "citr akara", "ciut", "clurit", "coak", "coang", "cob", "coba", "cobaan", "coban", "cobar", "cobek", "coblos", "cocok", "cocol", "cocor", "cocot", "coda", "codak", "codet", "codot", "cogah", "cogan", "cogok", "cok", "coka", "cokar", "cokek", "cokelat", "coki", "cokin", "coklat", "cokmar", "coko", "cokok", "cokol", "cokor", "cokot", "colak", "colek", "coleng", "colet", "coli", "colok", "colong", "colot", "comat", "comberan", "comblang", "combong", "comek", "comel", "comor", "compang", "comro", "concong", "condong", "conet", "congak", "congeh", "congek", "congget", "conggok", "congkah", "congkak", "congkel", "congki", "congklang", "congkok", "congkol", "congkong", "congo", "congok", "congol", "congor", "congsam", "cono", "conteng", "contok", "contong", "cop", "copar", "copet", "coplok", "copot", "cor", "corak", "coran", "corek", "coreng", "coret", "coro", "corong", "corot", "cotok", "cowok", "criping", "cuaca", "cuai", "cuak", "cual", "cuang", "cuar", "cuat", "cuba", "cuban", "cubit", "cublik", "cubung", "cuca", "cucak", "cuci", "cucu", "cucuh", "cucuk", "cucun", "cucunda", "cucung", "cucup", "cucur", "cucuran", "cucut", "cudang", "cuh", "cuik", "cuil", "cuing", "cuit", "cuj", "cuka", "cukai", "cuki", "cukil", "cukimai", "cukin", "cukit", "cukong", "cuku", "cukup", "cukur", "cula", "culak", "culam", "culan", "culas", "culik", "culika", "cuma", "cuman", "cumbu", "cumi", "cumik", "cumil", "cumpat", "cumpel", "cumplong", "cumu", "cun", "cuna", "cundang", "cundrik", "cunduk", "cung", "cungap", "cungkil", "cungkit", "cungkup", "cunguk", "cungul", "cunia", "cunjin", "cup", "cupai", "cupak", "cupang", "cupar", "cupet", "cuping", "cuplik", "cuplikan", "cupu", "cupul", "cura", "curah", "curai", "curam", "curang", "curat", "curek", "cureng", "curi", "curiah", "curiga", "curik", "curna", "curu", "cus", "cut", "cutak", "cutbrai", "cutel", "cuti"

--KATA HURUF D
  "d", "da", "dab", "daba", "dabih", "dabik", "dabit", "dabu", "dabus", "dacin", "dad", "dada", "dadah", "dadak", "dadal", "dadap", "dadar", "dadi", "dadih", "dadu", "dadung", "daerah", "dafnah", "daftar", "daga", "dagang", "dage", "dagel", "daging", "dagu", "dah", "daha", "dahaga", "dahak", "daham", "dahan", "dahi", "dahlia", "dahsyat", "dahulu", "dai", "daif", "daim", "daing", "dajal", "dak", "dakah", "dakar", "daki", "dakik", "dakon", "daksa", "daksina", "daktil", "dakwa", "dakwah", "dal", "dalal", "dalam", "dalang", "dalil", "dalu", "daluang", "daluwarsa", "dam", "damai", "damak", "damar", "damba", "dambin", "dampak", "dampal", "dampar", "damping", "damprat", "dan", "dana", "danau", "danawa", "dandan", "dandang", "dandi", "dang", "dangai", "dangau", "dangdut", "dangkal", "dangkar", "danguk", "dangus", "dani", "danyang", "dap", "dapa", "dapar", "dapat", "dapur", "dar", "dara", "darab", "darah", "daras", "darat", "darau", "dargah", "dari", "darma", "darmabakti", "darmawisata", "daro", "daru", "darurat", "darus", "das", "dasa", "dasar", "dasi", "dastar", "daster", "data", "datar", "dati", "datu", "datuk", "datung", "dauk", "daun", "daur", "dawai", "dawat", "dawet", "daya", "dayah", "dayak", "dayang", "dayu", "dayuh", "dayuk", "dayung", "dayus", "debah", "debak", "debap", "debar", "debarkasi", "debat", "debek", "debet", "debik", "debil", "debing", "debirokratisasi", "debit", "debitase", "debitor", "debu", "debuk", "debun", "debur", "debus", "debut", "decak", "decap", "decit", "decup", "decur", "dedah", "dedai", "dedak", "dedal", "dedalu", "dedap", "dedar", "dedara", "dedas", "dedau", "dedek", "dedel", "dedemit", "dedengkot", "deder", "dederuk", "dedes", "dedikasi", "deduksi", "deduktif", "deeskalasi", "defaitisme", "defekasi", "defender", "defensi", "defensif", "defile", "definisi", "definitif", "defisit", "deflasi", "defleksi", "deflorasi", "deformasi", "degam", "degan", "degap", "degar", "degil", "deging", "degup", "deham", "dehem", "dehidrasi", "dehidrogenasi", "dehumanisasi", "deideologisasi", "deifikasi", "deiksis", "deislamisasi", "deisme", "dek", "deka", "dekade", "dekaden", "dekadensi", "dekagram", "dekah", "dekak", "dekam", "dekan", "dekanal", "dekantasi", "dekap", "dekapoda", "dekar", "dekare", "dekat", "dekik", "dekil", "deklamasi", "deklamator", "deklarasi", "deklaratif", "deklasifikasi", "deklinasi", "dekolonisasi", "dekomposer", "dekomposisi", "dekompresi", "dekonstruksi", "dekontaminasi", "dekosistem", "dekremento", "dekremeter", "dekriminalisasi", "dekrit", "deksa", "deku", "dekunci", "dekus", "dekut", "delah", "delan", "delap", "delapan", "delat", "delegasi", "delegat", "delegitimasi", "delep", "deler", "delik", "delikan", "delikat", "delima", "delinkuen", "delinkuensi", "delman", "delong", "delta", "deltoid", "delu", "delusi", "delusif", "dem", "demagog", "demagogi", "demagogis", "demam", "demang", "demap", "demarkasi", "dematerialisasi", "demek", "demen", "demensi", "demiliterisasi", "demineralisasi", "demisioner", "demo", "demobilisasi", "demografi", "demografis", "demokrasi", "demokrat", "demokratis", "demokratisasi", "demon", "demoniak", "demonologi", "demonstran", "demonstrasi", "demonstratif", "demoralisasi", "demosi", "dempak", "dempam", "dempang", "dempel", "dempet", "dempir", "demplon", "dempok", "dempul", "dempung", "demung", "den", "dena", "denah", "denai", "denak", "denasalisasi", "denasionalisasi", "dendam", "dendang", "dendeng", "dendi", "dendrokronologi", "dendrologi", "deng", "dengak", "dengan", "dengap", "dengar", "dengih", "dengik", "dengki", "dengkul", "dengkung", "dengkur", "dengkus", "dengu", "denguk", "dengung", "dengus", "dengut", "denim", "denotasi", "denotatif", "densimeter", "densitas", "densitometer", "densitometri"

--KATA HURUF E
  "e", "ebek", "ebi", "eboni", "ebonit", "ebulisi", "ecek", "eceng", "ecer", "eceran", "edan", "edar", "edaran", "edisi", "edit", "editor", "editorial", "edukasi", "edukatif", "efek", "efektif", "efektivitas", "efektor", "efendi", "efisien", "efisiensi", "ego", "egois", "egoisme", "egoistis", "egos", "egosentris", "egrang", "eh", "eja", "ejaan", "ejakulasi", "ejek", "ejekan", "eka", "ekaristi", "eklips", "ekliptika", "eko", "ekologi", "ekologis", "ekonom", "ekonomi", "ekonomis", "ekor", "ekosistem", "ekosfer", "eks", "eksak", "eksakta", "eksamen", "eksaminasi", "eksaserbasi", "eksegesis", "eksekusi", "eksekutif", "eksekutor", "eksem", "eksemplar", "eksentrik", "eksepsi", "ekses", "eksesif", "eksfoliasi", "ekshalasi", "ekshibisi", "ekshibisionis", "ekshibisionisme", "eksim", "eksipien", "eksistensi", "eksistensial", "eksistensialis", "eksistensialisme", "eksit", "eksitasi", "ekskavasi", "ekskavator", "eksklave", "eksklusif", "eksklusivisme", "ekskomunikasi", "ekskresi", "ekskreta", "ekskursi", "ekskursif", "ekso", "eksobiologi", "eksodermis", "eksodus", "eksogami", "eksogen", "eksokrin", "eksorbitan", "eksorsis", "eksorsisme", "eksoterm", "eksoterik", "eksotik", "eksotis", "eksotisme", "ekspansi", "ekspansionis", "ekspansionisme", "ekspatriasi", "ekspatriat", "ekspedir", "ekspedisi", "eksped isien", "ekspeditur", "eksperimen", "eksperimental", "ekspres", "ekspresi", "ekspresif", "ekspresionis", "ekspresionisme", "ekspresivitas", "ekspropriasi", "ekstase", "ekstasi", "ekstensi", "ekstensif", "ekstensifikasi", "ekstensitas", "eksterior", "ekstern", "eksternal", "eksternalisasi", "eksternat", "eksternir", "ekstra", "ekstradisi", "ekstrak", "ekstraksi", "ekstraktif", "ekstrakurikuler", "ekstramarital", "ekstranei", "ekstrapolasi", "ekstraseluler", "ekstraterestrial", "ekstrateritorial", "ekstravaganza"

--KATA HURUF F
  "f", "fa", "faal", "fabel", "fabrik", "fabrikasi", "fadil", "fadilah", "faedah", "fagir", "faham", "fajar", "fakih", "fakir", "faks", "faksi", "faksimile", "fakta", "faktif", "faktor", "faktorial", "faktual", "faktur", "fakultas", "fakultatif", "falak", "falsafah", "famili", "familiar", "fana", "fanatik", "fanatisme", "fantasi", "fantastis", "fantom", "faraid", "fardu", "faring", "faringitis", "farmasi", "farmakologi", "farsakh", "fasa", "fasad", "fase", "faset", "fasih", "fasik", "fasilitas", "fasilitasi", "fasilitator", "fasis", "fasisme", "fatal", "fatalis", "fatalisme", "fatalitas", "fatamorgana", "fatihah", "fatwa", "fauna", "favorit", "favoritisme", "federal", "federalisme", "federasi", "februari", "feldspar", "feminin", "feminis", "feminisme", "femur", "fengsui", "fenol", "fenomen", "fenomena", "fenomenal", "fenomenologi", "fenotipe", "feri", "feromagnetik", "feromon", "ferum", "feses", "festival", "fetish", "fetisisme", "fetus", "fi", "fial", "fiasco", "fiber", "fibril", "fibrin", "fibrinogen", "fibroin", "fibroma", "fibrosis", "fidah", "fidyah", "figur", "figuratif", "fikih", "fiksi", "fiktif", "filamen", "filantrop", "filantropi", "filantropis", "filariasis", "filem", "filharmoni", "filogeni", "filolog", "filologi", "filologis", "filsafat", "filsuf", "filter", "filtrasi", "filtrat", "final", "finalis", "finalisasi", "finansial", "finis", "firma", "firman", "fis", "fisibel", "fisibilitas", "fisik", "fisikawan", "fisika", "fisiognomi", "fisiologi", "fisiologis", "fisioterapi", "fisis", "fision", "fisura", "fitnah", "fitofag", "fitogen", "fitogeografi", "fitokimia", "fitopatologi", "fitosterol", "fitoterapi", "fitotoksin"

--KATA HURUF G
  "g", "ga", "gabah", "gabai", "gabak", "gabas", "gabir", "gabuk", "gabung", "gabus", "gada", "gadai", "gadang", "gading", "gadis", "gado", "gaduh", "gaduk", "gadung", "gaek", "gaet", "gafar", "gagah", "gagak", "gagal", "gagang", "gagap", "gagar", "gagasan", "gagau", "gaham", "gahar", "gaharu", "gaib", "gairah", "gait", "gajah", "gaji", "gajih", "gajul", "gala", "galah", "galak", "galaksi", "galaktosa", "galang", "galar", "galas", "galat", "galau", "gali", "galib", "galih", "galing", "galir", "galon", "galuh", "galung", "galur", "galvanis", "galvanisasi", "gam", "gamak", "gamal", "gamam", "gaman", "gamang", "gamat", "gambar", "gambas", "gambir", "gamblang", "gambling", "gambuh", "gambus", "gambut", "gamelan", "gamis", "gamit", "gamma", "gampang", "gampar", "gamping", "gana", "ganas", "gancang", "gancar", "gancu", "ganda", "gandal", "gandar", "gandaria", "gandeng", "ganden", "gandik", "ganding", "gandok", "gandrung", "gandum", "gandung", "gang", "ganggang", "ganggu", "gangsa", "gangsal", "gangsar", "gangsi", "gangsir", "ganjal", "ganjar", "ganjil", "ganjur", "ganta", "gantang", "gant el", "ganteng", "ganti", "gantih", "ganting", "gantung", "ganua", "gap", "gapai", "gapil", "gapit", "gaple", "gaplek", "gaplok", "gapuk", "gapura", "gara", "garaj", "garam", "garan", "garang", "garansi", "garap", "garasi", "garau", "garba", "garda", "gardan", "gardu", "garing", "garindin", "garis", "garit", "garong", "garpu", "garu", "garuda", "garuk", "garung", "garut", "gas", "gasak", "gasal", "gasang", "gasir", "gasket", "gasolin", "gastrektomi", "gastrin", "gastritis", "gastroenteritis", "gastrointestinal", "gastroskopi", "gatal", "gatot", "gatra", "gauk", "gaul", "gaun", "gaung", "gawai", "gawang", "gawar", "gawat", "gawir", "gaya", "gayal", "gayam", "gayang", "gayat", "gayau", "gayeng", "gayuh", "gayuk", "gayun", "gayung", "gayut", "gebah", "gebang", "gebar", "gebe", "gebeng", "geber", "gebok", "gebos", "gebot", "gebrak", "gebu", "gebuk", "gebyar", "gecak", "gecek", "gecik", "geco", "ge cok", "gedabah", "gedana", "gedang", "gedanjir", "gedebak", "gedebar", "gedebok", "gedebuk", "gedeh", "gedek", "gedempung", "gedeng", "geding", "gedobok", "gedombak", "gedombrongan", "gedong", "gedongan", "gedor", "gedubang", "gedung", "gegabah", "gegadan", "gegai", "ge gak", "gegan", "ge gana", "gegap", "gegar", "gegas", "gegat", "gegau", "gegep", "geger", "gegisik", "gegit", "geguntang", "geh", "gehu", "gejala", "gejolak", "gejos", "gel", "gela", "geladak", "geladir", "geladrah", "gelagah", "gelagap", "gelagar", "gelagat", "gelak", "gelakak", "gelam", "gelamai", "gelambir", "gelandang", "gelang", "gelanggang", "gelandangan", "gelantang", "gelanting", "gelantung", "gelap", "gelapit", "gelar", "gelas", "gelasah", "gelatak", "gelatik", "gelatuk", "gelebap", "gelebar", "geleber", "gelebuk", "geleca", "gelecik", "geledah", "geledang", "geledek", "geleding", "geledur", "gelegak", "gelegar", "gelegata", "gelek", "gelekak", "gelekek", "gelembung", "gelembur", "gelempang", "gelemprang", "gelendong", "gelendot", "geleng", "gelenggang", "gelenyar", "gelepak", "gelepar", "gelepek", "gelepot", "gelepung", "gelepur", "gelesek", "geleser", "gelesot", "geletak", "geletar", "geletek", "geletik", "geleting", "geletis", "geletuk", "geli", "geliang", "geliat", "gelicik", "geligi", "geligin", "geligis", "geligit", "gelimang", "gelimun", "gelincir", "gelincuh", "gelinding", "gelinggam", "gelinggaman", "gelinggang", "gelingsir", "gelinjang", "gelintar", "gelintin", "gelinting", "gelisah", "gelita", "gelitar", "geliut", "gelobok", "gelodar", "gelodok", "gelogok", "gelohok", "gelojoh", "gelok", "gelompo", "gelombang", "gelondong", "gelondongan", "gelonggong", "gelongsong", "gelora", "gelosang", "geloso", "gelosok", "gelotak", "geluduk", "geluga", "gelugu", "gelugur", "gelugut", "geluh", "geluk", "gelulur", "gelumpung", "geluncur", "gelundung", "gelung", "gelup", "gelupur", "gelut", "gema", "gemak", "gemal", "geman", "gemang", "gemap", "gemar", "gemas", "gembal", "gembala", "gembar", "gembel", "gembeng", "gember", "gembili", "gembira", "gemblak", "gembleng", "gembok", "gembol", "gembong", "gembor", "gembos", "gembreng", "gembrot", "gembuk", "gembung", "gembur", "gembus", "gembut", "gemebyar", "gemeh", "gemela", "gemelentam", "gemen", "gemercak", "gemercik", "gemercing", "gemerencang", "gemerencik", "gemerencing", "gemerencung", "gemeresik", "gemeretak", "gemeretuk", "gemeretup", "gemerlap", "gemerlapan", "gemertak", "gemertuk", "gemerut", "gemetar", "gemetuk", "gemi", "gemik", "gemilang", "gemilap", "geming", "geminasi", "gempa", "gempal", "gempar", "gempil", "gempita", "gempol", "gempor", "gempur", "gemuk", "gemul", "gemulai", "gemulung", "gemuntur", "gemuruh", "gen", "genah", "genahar", "genang", "genap", "gencar", "gencat", "gencet", "gencetan", "genjang", "genjik", "genjot", "genjrang", "genjring", "genjur", "genre", "genta", "gentala", "gentas", "gentat", "gentayang", "gentel", "genteng", "genting", "gentis", "genuin", "genus", "geodesi", "geofisika", "geofisikawan", "geografi", "geografis", "geokimia", "geokronologi", "geolog", "geologi", "geologis", "geomagnet", "geomagnetisme", "geometri", "geometris", "geopolitik", "georgette", "geoteknik", "geotropisme", "gepeng", "gepok", "gepu", "ger", "gera", "gerabah", "gerabak", "gerabang", "geragai", "geragap", "geragas", "geragau", "geragih", "geraguk", "gerah", "geraham", "gerai", "gerak", "gerakan", "geram", "geraman", "geramang", "geramsut", "geramus", "gerang", "gerangan", "geranggang", "geranium", "gerantak", "gerantang", "geranyam", "gerapai", "gerapu", "gerat", "geratak", "geratih", "gerau", "gerawan", "gerawat", "gerayah", "gerayang", "gerbang", "gerbong", "gerbu", "gerda", "gerdam", "gerdum", "gerebak", "gerebek", "gerecak", "gerecok", "geren", "gerencang", "gerendang", "gerendeng", "gerenek", "gereneng", "gerengseng", "gerenjeng", "gerenjet", "gerentang", "gerenyau", "gerenyeng", "gerenyet", "gerenying", "gerenyit", "gerenyot", "gerepe", "gerepek", "gerepes", "geresek", "geret", "geretak", "geretang", "geretan", "gerha", "gerhana", "geriak", "geriap", "geriatrik", "geribik", "gericau", "geridip", "geridit", "gerigi", "gerigik", "gerigis", "gerigit", "gerih", "gerik", "gerilya", "gerim", "gerimis", "gerincing", "gerinda", "gerindil", "gerinding", "gerinjal", "gerinjam", "gerinting", "gerinyau", "gerinyut", "gerip", "geripir", "gerisik", "gerising", "gerit", "gerita", "geriuk", "gerlap", "gerlip", "germang", "germanium", "germinasi", "germo", "gerobak", "gerobok", "gerobyak", "gerocok", "geroda", "gerogol", "gerogot", "gerohok", "gerohong", "gerojok", "gerombol", "gerombolan", "gerompok", "gerong", "geronggang", "geronium", "gerontang", "gerontokrasi", "geropol", "geros", "gerosak", "gerot", "gerotot", "gerowong", "gerowot", "gerpol", "gerr", "gersak", "gersang", "gersik", "gertak", "gertakan", "gertik", "gertuk", "geru", "gerugut", "geruh", "geruit", "gerum", "gerumbul", "gerumut", "gerun", "gerundang", "gerundel", "gerung", "gerunggung", "gerup", "gerupis", "gerupuk", "gerus", "gerut", "gerutu", "gerutup", "gerutus", "gesa", "gesek", "gesel", "geser", "gesit", "gesper", "gestikulasi", "geta", "getah", "getak", "getang", "getap", "getar", "getaran", "getas", "getek", "getem", "geti", "getik", "getil", "getir", "getis", "getok", "getol", "getu", "getuk", "getun", "gewang", "geya", "geyong", "ghaib", "ghalib", "gharib", "ghayah", "ghazal", "giat", "gibah", "giblet", "gigahertz", "gigantisme", "gigil", "gigis", "gigit", "gil", "gila", "gilang", "gilap", "gilas", "gilau", "gili", "giligan", "giliran", "gilung", "gim", "gimnasium", "gimnastik", "gimpal", "gin", "gina", "gincu", "ginding", "ginekomasti", "ginekolog", "ginekologi", "gingsir", "ginseng", "gir", "girah", "girang", "giras", "giri", "girik", "giring", "giris", "giro", "giroskop", "gisik", "gitar", "gitaris", "gites", "gitik", "giur", "giwang", "gladiator", "gladiol", "glamour", "glaukoma", "gliserin", "global", "globalisasi", "globulin", "glosarium", "glosem", "glositis", "glucagon", "gluon", "glutamat", "gluten", "gobah", "gobak", "gobang", "gobar", "gobek", "gobet", "goblok", "gocap", "gocek", "gocoh", "goda", "godaan", "godak", "godam", "godek", "godok", "godong", "godot", "goel", "goet", "gogoh", "gogok", "gogos", "gogrok", "gohok", "gohong", "gojek", "gojlok", "gokar", "gol", "golak", "golbi", "golek", "goleng", "golet", "golf", "golok", "golong", "golongan", "golpi", "gom", "gombak", "gombal", "gombang", "gombeng", "gombrang", "gomok", "gompal", "gompiok", "gonad", "gondang", "goncang", "gondok", "gondola", "gondong", "gondorukem", "gondrong", "gong", "gonggong", "gongli", "gongseng", "goni", "gonidium", "goniometri", "gonjang", "gonjing", "gonjlang", "gonjok", "gonjong", "gonore", "gontai", "gontok", "gonyak", "gonyeh", "gonyel", "gonyoh", "gorap", "gorden", "gorek", "gores", "goresan", "gori", "gorila", "goroh", "gorok", "goryak", "gosip", "gosok", "gosokan", "got", "gotes", "gotik", "gotong", "gotri", "gotrok", "gotun", "gowok", "goyang", "grabadan", "grad", "gradasi", "gradien", "gradual", "graf", "grafem", "grafemik", "grafemis", "grafetik", "grafik", "grafika", "grafis", "grafit", "grafologi", "graha", "gram", "gramatik", "gramatika", "gramatikal", "grambyang", "gramofon", "granat", "granit", "grantang", "granula", "granulasi", "granuloma", "grapyak", "grasi", "gratifikasi", "gratis", "gravel", "graver", "gravitasi", "gravimeter", "gravimetri", "grehon", "gresek", "grip", "griya", "grogi", "gros", "grosir", "grup", "gu", "gua", "gual", "guam", "guanin", "guar", "gubah", "gubal", "gubang", "gubel", "gubernemen", "gubernur", "gubit", "gubris", "gubuk", "guci", "gudam", "gudang", "gude", "gudik", "gufra", "gugar", "gugat", "gugatan", "gugu", "guguh", "guguk", "gugup", "gugur", "gugus", "guha", "guhuk", "guik", "guis", "guk", "gula", "gulah", "gulai", "gulali", "gulam", "gulambai", "gulana", "gulas", "gulat", "gulek", "guli", "guliga", "guling", "gulir", "gulita", "gulma", "gulud", "guludan", "gulung", "gulut", "gum", "g umal", "gumam", "gumbuk", "gumen", "gumuk", "gumul", "gumun", "gun", "guna", "gunawan", "guncang", "gundah", "gundal", "gundala", "gundang", "gundar", "gundi", "gundik", "gundu", "gundul", "gung", "gunggung", "gunjai", "gunjing", "gunting", "guntingan", "guntur", "gunung", "gup", "gurah", "guram", "gurami", "gurat", "gurau", "gurdan", "gurdi", "guri", "gurih", "gurik", "gurindam", "guring", "gurit", "gurita", "gurnadur", "guru", "gurub", "guruh", "guruk", "gurun", "gurung", "gurur", "gus", "gusel", "gusi", "gusti", "gutik", "gutis", "gutural", "guyon", "guyot", "guyur"

--KATA HURUF H
  "h", "ha", "habib", "habil", "habis", "habitat", "habitus", "hablur", "had", "hadang", "hadap", "hadapan", "hadas", "hadat", "hadiah", "hadir", "hadirat", "hadirin", "hadis", "hafal", "hafalan", "hafiz", "hafnium", "hai", "haid", "haik", "hail", "hajar", "hajat", "haji", "hak", "hakam", "hakikat", "hakiki", "hakim", "hak ul", "hakulyakin", "hal", "hala", "halai", "halal", "halaman", "halang", "halangan", "halau", "halte", "halter", "haluan", "halus", "halusinasi", "halusinogen", "ham", "hama", "hamba", "hambar", "hambat", "hambatan", "hambur", "hamburger", "hamdalah", "hamil", "hampa", "hampar", "hamparan", "hampir", "hamster", "hamzah", "hanafi", "hancur", "handai", "handal", "handuk", "hang", "hangar", "hangat", "hanggar", "hangit", "hangus", "hanif", "hanjuang", "hansip", "hantam", "hantaman", "hantar", "hantaran", "hantu", "hanya", "hanyir", "hanyut", "hap", "hapal", "haploid", "hapus", "hara", "harak", "harakah", "harakiri", "haram", "harap", "harapan", "hardik", "hardikah", "harem", "harendong", "harfiah", "harga", "hari", "harian", "harimau", "haring", "haris", "harisah", "harit", "harkat", "harmoni", "harmonik", "harmonika", "harmonis", "harmonisasi"

--KATA HURUF I
  "i", "ia", "ialah", "iba", "ibadah", "ibadat", "ibarat", "ibil", "iblis", "ibu", "ibukota", "ibunda", "icip", "idah", "idam", "idaman", "idap", "ide", "ideal", "idealis", "idealisme", "idealistis", "identifikasi", "identik", "identitas", "ideologi", "ideologis", "idiom", "idiomatis", "idiot", "idola", "iduladha", "idulfitri", "ifrit", "iftitah", "iga", "igal", "igau", "iguana", "ih", "ihlas", "ihram", "ihsan", "ihtiar", "ihwal", "ijab", "ijabah", "ijasah", "ijazah", "ijmak", "ijmal", "ijon", "ijtihad", "ijuk", "ikal", "ikan", "ikat", "ikatan", "ikhbar", "ikhlas", "ikhtiar", "ikhtilaf", "ikhtisar", "ikhwan", "iklan", "iklim", "ikon", "ikonografi", "ikrab", "ikram", "ikrar", "iktibar", "iktikad", "ikut", "ilah", "ilahi", "ilahiah", "ilai", "ilalang", "ilam", "ilat", "ilegal", "ileg", "ilham", "ili", "ilik", "ilmu", "ilmiah", "ilmiyah", "ilusi", "ilusionis", "ilustrasi", "ilustratif", "ilustrator", "imajinasi", "imajinatif", "imajiner", "imam", "imamah", "iman", "imanen", "imani", "imbal", "imbangi", "imbas", "imbau", "imbuh", "imigran", "imigrasi", "iming", "imitasi", "imitatif", "imobilisasi", "impak", "impas", "impase", "impedansi", "imperatif", "imperial", "imperialis", "imperialisme", "imperio", "imperium", "impersonalia", "impetigo", "impi", "impit", "implan", "implementasi", "implikasi", "implisit", "impor", "importasi", "importir", "impoten", "impotensi", "impregnasi", "impresariat", "impresario", "impresif", "impresionis", "impresionisme", "imprimatur", "improvisasi", "impuls", "impulsif", "imunitas", "imunisasi", "imunologi", "inai", "inang", "inap", "inas", "inaugurasi", "incar", "inci", "incinerator", "indera", "inderawi", "indeks", "inden", "independent", "indah", "indang", "indap", "indekos", "indentasi", "independen", "index", "india", "indian", "indikator", "inding", "individual", "individualis", "individualisme", "individualistis", "individuasi", "indoktrinasi", "indolen", "indologi", "indonesia", "indra", "indu", "induk", "induksi", "induktif", "induktor", "industri", "industrialisasi", "industrialis", "industriawan", "inefisien", "inefisiensi", "inekuitas", "inersia", "inersial", "infak", "infertil", "infertilitas", "infiltrasi", "infinitif", "infix", "inflamasi", "inflasi", "infleksi", "inflik", "infl uensa", "info", "inform", "informal", "informan", "informasi", "informatif", "informatika", "infrastruktur", "inframerah", "infrasonik", "infus", "ingar", "ingat", "ingatan", "ingau", "inggang", "inggris", "ingin", "ingkah", "ingkar", "ingus", "inisial", "inisiasi", "inisiatif", "injak", "injap", "injeksi", "injil", "inkarnasi", "inklusi", "inklusif", "inkognito", "inkonsisten", "inkonsistensi", "inkubasi", "inkubator", "inkuisisi", "inkuisitor", "innovasi", "innovatif", "inokulasi", "input", "insan", "insaf", "insektisida", "insektarium", "insektologi", "inseminasi", "insensi", "insentif", "inser", "insersi", "insidensi", "insiden", "insinerator", "insinuasi", "insolven", "insolvensi", "inspeksi", "inspektorat", "inspektur", "inspirasi", "instalasi", "instalatur", "instan", "insting", "institusi", "institusional", "instruksi", "instruktif", "instruktur", "instrumen", "instrumental", "instrumentalia", "instrumentasi", "insubordinasi", "insufisiensi", "insulin", "insurans", "intai", "intan", "integral", "integrasi", "integrasionis", "integritas", "integumen", "intelek", "intelektual", "intelektualisme", "inteligensi", "inteligensia", "inteli", "inten", "intens", "intensi", "intensif", "intensifikasi", "intensitas", "inter", "interaksi", "interaktif", "interdependen", "interdependensi", "interdisipliner", "interest", "interfensi", "interferensi", "interim", "interjeksi", "interkom", "interkoneksi", "interlokal", "interlud", "intermezzo", "intermediate", "intermeso", "internal", "internalisasi", "internasio", "internasional", "internasionalisasi", "internat", "internet", "internis", "internir", "interogasi", "interogatif", "interpelasi", "interpelan", "interphase", "interpolasi", "interpretasi", "interpretatif", "interpreter", "interupsi", "interval", "intervensi", "interviu", "inti", "intifadah", "intim", "intima", "intimasi", "intimidasi", "intip", "intipati", "intoleran", "intoleransi", "intonasi", "intra", "intradermal", "intramuskular", "intransitif", "intravena", "intrig", "intrinsik", "intro", "introduksi", "introjeksi", "introspeksi", "introver", "introversi", "intuisi", "intuitif", "intumesensi", "invasi", "inventaris", "inventarisasi", "inventif", "inventori", "inversi", "invertebrata", "investasi", "investigasi", "investigatif", "investor", "inviabilitas", "invitro", "invokal", "invo", "invoice", "involusi", "ion", "ionisasi", "ionosfer", "iota", "ipar", "ipil", "ipoh", "ipuh", "ipuk", "iq", "iradat", "irah", "irama", "irap", "iras", "irasan", "irelevan", "iregular", "iregularitas", "iri", "iridium", "irigasi", "irigator", "irik", "iring", "iris", "irisan", "irit", "iritabilitas", "iritasi", "ironia", "ironi", "ironis", "irsyad", "irung", "isa", "isak", "isap", "isapan", "isbat", "iseng", "isian", "isim", "isit", "islam", "islamisasi", "islami", "islamiah", "islamologi", "isme", "iso", "isolasi", "isolasionisme", "isolator", "isomer", "isometrik", "isomorf", "isomorfisme", "isonim", "isopraksa", "isoterma", "isotonik", "isotop", "isotrop", "istimewa", "istri", "isyarat", "itik", "itikad", "itil", "itulah", "itung", "iur", "iuran", "iwada", "iya", "izah", "izin"

--KATA HURUF J
  "j", "ja", "jabat", "jabatan", "jadi", "jadwal", "jaga", "jagad", "jagal", "jagat", "jago", "jagung", "jagur", "jahanam", "jahat", "jahe", "jahil", "jahiliah", "jahit", "jail", "jaja", "jajah", "jajahan", "jajak", "jajal", "jajan", "jajar", "jajaran", "jaka", "jaket", "jaksa", "jakun", "jala", "jalan", "jalang", "jalar", "jali", "jalin", "jalur", "jam", "jamaah", "jamah", "jamak", "jaman", "jamang", "jamas", "jamba", "jambak", "jambal", "jamban", "jambang", "jambar", "jambat", "jambe", "jambi", "jambu", "jambul", "jamik", "jamin", "jaminan", "jampi", "jamu", "jamur", "janda", "jangan", "jangar", "jangka", "jangkah", "jangkang", "jangkar", "jangkau", "jangkrik", "jangkung", "janggut", "janin", "janji", "jantan", "jantang", "jantung", "jantur", "janturan", "jara", "jarak", "jarang", "jaras", "jariah", "jaring", "jaringan", "jarit", "jarum", "jarwa", "jasa", "jasad", "jasmani", "jasmaniah", "jasus", "jatah", "jati", "jatuh", "jauh", "jawab", "jawat", "jawatan", "jawi", "jawil", "jaya", "jaz", "jazirah", "jean", "jebah", "jebai", "jebak", "jebakan", "jebang", "jebar", "jebat", "jebik", "jebol", "jebor", "jebrol", "jebur", "jeda", "jegal", "jegang", "jeger", "jegil", "jegogan", "jegung", "jejas", "jejak", "jejaka", "jejal", "jejam", "jejangkungan", "jejantung", "jejari", "jejarnasi", "jejawi", "jejek", "jejeran", "jela", "jelabak", "jelabur", "jeladan", "jeladren", "jeladri", "jelaga", "jelagra", "jelah", "jelai", "jelajah", "jelak", "jelalat", "jelamprang", "jelanak", "jelang", "jelangak", "jelangkung", "jelantah", "jelapak", "jelapang", "jelar", "jelas", "jelata", "jelatang", "jelau", "jelek", "jelih", "jelir", "jelita", "jelma", "jelu", "jelujur", "jeluk", "jelum", "jelungkap", "jelunut", "jemaah", "jemaat", "jemah", "jeman", "jember", "jembatan", "jempalik", "jempol", "jemput", "jemputan", "jemu", "jemuas", "jemur", "jemuran", "jenaka", "jenang", "jenangau", "jenat", "jenawi", "jenayah", "jenazah", "jendal", "jendala", "jendel", "jendela", "jenderal", "jendul", "jeneng", "jeng", "jengah", "jengat", "jengek", "jenggar", "jengger", "jengget", "jengguk", "jenggul", "jenggut", "jengit", "jengkal", "jengkang", "jengkek", "jengkel", "jengkelit", "jengkeng", "jengker", "jengket", "jengki", "jengking", "jengkit", "jengkol", "jengkot", "jengkuk", "jenguk", "jengul", "jenis", "jenius", "jenjang", "jenjeng", "jentaka", "jentel", "jentera", "jentik", "jentikan", "jentur", "jepang", "jepret", "jepretan", "jera", "jerah", "jerahak", "jerahap", "jerait", "jerajak", "jeram", "jerambah", "jerambai", "jerami", "jerang", "jerangan", "jerangkak", "jerangkang", "jerap", "jerat", "jerau", "jeraus", "jerawat", "jerba", "jerembab", "jerembap", "jerembat", "jerembet", "jerembun", "jerempak", "jereng", "jerepet", "jeri", "jeriau", "jerigen", "jerih", "jering", "jeringing", "jerit", "jerjak", "jermal", "jermang", "jernang", "jernih", "jerok", "jeroan", "jerongkang", "jerongkong", "jeruk", "jeruki", "jerumu", "jerung", "jerupa", "jes", "jet", "jetis", "jibril", "jibun", "jida", "jidal", "jidat", "jidor", "jidur", "jiwa", "jigong", "jihan", "jihat", "jijik", "jijit", "jila", "jilah", "jilam", "jilat", "jilbab", "jilid", "jim", "jimak", "jimat", "jimbit", "jin", "jinak", "jinayah", "jindan", "jinem", "jingau", "jingga", "jinggring", "jingkat", "jingkau", "jingkik", "jingkrak", "jingo", "jingoisme", "jinjang", "jinjing", "jinjit", "jinsom", "jipro", "jiran", "jirat", "jirus", "jisim", "jitah", "jitu", "jizyah", "jobak", "jobong", "jodang", "jodoh", "jodong", "jogan", "jogar", "joget", "joging", "joglo", "johar", "johari", "jojol", "joki", "jol", "jolak", "jolek", "joli", "jolok", "jolong", "jolor", "jombang", "jompo", "jompong", "jongang", "jonget", "jonggol", "jongkah", "jongkang", "jongkar", "jongkat", "jongki", "jongko", "jongkok", "jongkong", "jongos", "jontoh", "jorjoran", "jorok", "jorong", "jos", "jota", "jotika", "jotos", "joule", "jreng", "juak", "jual", "juang", "juara", "jubah", "jubel", "jubin", "jubir", "jubur", "juda", "judi", "judo", "judoka", "judul", "juek", "juga", "jugil", "juhi", "juhut", "juita", "jujah", "jujai", "jujitsu", "jujur", "jujuran", "jujut", "jukata", "juki", "jukut", "julai", "julang", "julap", "julat", "juli", "julig", "julir", "julo", "juluk", "julung", "julur", "jumah", "jumantara", "jumat", "jumbai", "jumbil", "jumbo", "jumbuh", "jumhur", "jumjumah", "jumlah", "jumpa", "jumpalit", "jumpalitan", "jumpang", "jumpelang", "jumpul", "jumput", "jumrah", "jumud", "jun", "junam", "jundai", "jung", "jungat", "junggang", "jungkal", "jungkang", "jungkar", "jungkat", "jungkel", "jungkir", "jungkit", "jungkol", "jungur", "jungut", "juni", "junior", "junjung", "junta", "juntai", "juntrung", "jupang", "jurai", "jurang", "juri", "jurik", "jurit", "jurnal", "jurnalisme", "jurnalis", "jurnalistik", "juru", "juruh", "jurus", "jurusan", "jus", "justifikasi", "justru", "juta", "jutawan", "jute", "juwita", "juz"

--KATA HURUF K
  "k", "ka", "kabar", "kabel", "kabin", "kabinet", "kabul", "kabung", "kabupaten", "kabur", "kabus", "kabut", "kaca", "kacak", "kacang", "kacau", "kacek", "kacer", "kaci", "kacip", "kacuk", "kacung", "kada", "kadal", "kadaluarsa", "kadam", "kadang", "kadar", "kadas", "kader", "kadet", "kadi", "kadim", "kado", "kaduk", "kaedah", "kafan", "kafe", "kafir", "kaget", "kagok", "kagum", "kahaf", "kahar", "kahat", "kahin", "kahwa", "kai", "kaidah", "kail", "kain", "kais", "kaisar", "kait", "kaitan", "kaji", "kajian", "kak", "kaka", "kakak", "kakaktua", "kakang", "kakao", "kakap", "kakar", "kakas", "kakatua", "kakek", "kakerlak", "kaki", "kakofoni", "kakografi", "kakota", "kaku", "kakus", "kala", "kalah", "kalai", "kalajengking", "kalak", "kalam", "kalamba", "kalamin", "kalan", "kalang", "kalangan", "kalap", "kalar", "kalas", "kalat", "kalau", "kalaupun", "kalawija", "kalbi", "kalbu", "kaleidoskop", "kalem", "kalender", "kaleng", "kalesa", "kali", "kalian", "kaliber", "kalibut", "kalifah", "kaligrafi", "kaligrafis", "kalih", "kalim", "kalimah", "kalimantang", "kalimatusyahadat", "kalio", "kalipso", "kaliptra", "kalis", "kalium", "kalk", "kalkalah", "kalkarium", "kalkasar", "kalkulasi", "kalkulator", "kalkulus", "kalkun", "kalomel", "kalong", "kalor", "kalori", "kalorimeter", "kalorimetri", "kaloris", "kalorisasi", "kalpataru", "kalsa", "kalsedon", "kalsifikasi", "kalsinasi", "kalsit", "kalsium", "kalui", "kalung", "kalus", "kalut", "kam", "kamal", "kamarsusu", "kamar", "kamariah", "kamas", "kamat", "kamba", "kamban", "kambang", "kambar", "kambeh", "kambing", "kambuh", "kambus", "kamelia", "kamera", "kamerawan", "kamerun", "kamhi", "kami", "kamil", "kamis", "kamisa", "kamit", "kamp", "kampa", "kampanye", "kampas", "kampemen", "kamper", "kampil", "kamping", "kampiun", "kampos", "kampret", "kampuh", "kampul", "kampung", "kampus", "kamu", "kamuflase", "kamus", "kan", "kana", "kanabis", "kanah", "kanal", "kanalisasi", "kanan", "kanang", "kanape", "kanari", "kanasta", "kancah", "kancap", "kanceh", "kancera", "kancil", "kancing", "kancung", "kanda", "kandang", "kandar", "kandas", "kandela", "kandidat", "kandidiasis", "kandil", "kandis", "kando", "kandung", "kandungan", "kang", "kangar", "kangen", "kangguru", "kangka", "kangkang", "kangkung", "kangmas", "kangsa", "kangsar", "kangtau", "kanguru", "kanibalisasi", "kanibal", "kanibalisme", "kanigara", "kanin", "kanis", "kanisah", "kanjang", "kanjar", "kanjeng", "kanji", "kanon", "kanonis", "kanonisasi", "kanopi", "kans", "kansa", "kansel", "kanselir", "kanser", "kantung", "kaos", "kap", "kapa", "kapabel", "kapah", "kapai", "kapak", "kapal", "kapan", "kapang", "kapar", "kaparinyo", "kapas", "kapasitor", "kapat", "kapel", "kapela", "kaper", "kapi", "kapila", "kapilaritas", "kapiler", "kapiran", "kapis", "kapisa", "kapisah", "kapista", "kapit", "kapitan", "kapitasi", "kapitulasi", "kapitulatif", "kapitulir", "kapok", "kapolsek", "kapolres", "kapolda", "kapolri", "kaprah", "kapri", "kaprikornus", "kapsul", "kapten", "kapu", "kapuk", "kapul", "kapulaga", "kapur", "kapuran", "kara", "karabin", "karah", "karak", "karakter", "karakteristik", "karakterisasi", "karam", "karamba", "karambol", "karamel", "karamelisasi", "karang", "karangan", "karantina", "karap", "karapan", "karar", "karas", "karat", "karatan", "karate", "karateka", "karau", "karavan", "karawitan", "karbon", "karbonado", "karbonan", "karbonat", "karbonisasi", "karbonil", "karbunkel", "karbohidrat", "karbol", "karbolik", "karburator", "karcis", "kardan", "kardigan", "kardinal", "kardiograf", "kardiografi", "kardiogram", "kardiolog", "kardiologi", "kardiovaskular", "kare", "kareba", "karedok", "kareh", "karel", "karen", "karena", "karengga", "karet", "kargo", "kari", "karib", "karibu", "karier", "karies", "karikatur", "karikatural", "karikaturis", "karil", "karim", "karina", "karinasi", "karisma", "karismatik", "kartu", "kartun", "kartunis", "karun", "karung", "karunia", "karut", "karya", "karyawan", "karyawati", "kas", "kasa", "kasab", "kasad", "kasah", "kasai", "kasak", "kasam", "kasang", "kasap", "kasar", "kasasi", "kasatmata", "kasau", "kasawi", "kasein", "kasemat", "kasemek", "kaset", "kasih", "kasihan", "kasim", "kasima", "kasino", "kasip", "kasir", "kaskade", "kaskaya", "kasmaran", "kasmutik", "kaspin", "kasrah", "kasregister", "kasta", "kastai", "kastanye", "kastel", "kaster", "kasti", "kastil", "kasuari", "kasuarina", "kasui", "kasuis", "kasuistik", "kasus", "kasut", "kata", "katabolisme", "katak", "kataklisme", "katakana", "katalase", "katalepsia", "katalina", "katalis", "katalisasi", "katalisator", "katalog", "katalogisasi", "katalogus", "katamaran", "katapel", "katar", "katarak", "kate", "katebelece", "kategori", "kategoris", "kategorisasi", "kateke", "katekese", "katekis", "katekisasi", "katekismus", "katekumen", "katel", "katelum", "katedral", "kategorial", "kater", "katering", "kates", "kateter", "kateterisasi", "katil", "katimum", "kation", "katir", "katode", "katolik", "katrol", "katuk", "katul", "katun", "katung", "katup", "katut", "kau", "kaul", "kaulah", "kaulan", "kauli", "kaum", "kausa", "kausal", "kausalitas", "kausatif", "kaustik", "kaut", "kavaleri", "kaveling", "kaver", "kawah", "kawak", "kawal", "kawalan", "kawan", "kawang", "kawanan", "kawat", "kawedanan", "kawi", "kawin", "kawista", "kawt", "kaya", "kayai", "kayak", "kayal", "kayan", "kayang", "kayangan", "kayau", "kayuh", "kayun"
}


-- ======================
-- FLOATING LOGO
-- ======================
local LogoBtn = Instance.new("ImageButton")
LogoBtn.Name = "Logo"
LogoBtn.Size = UDim2.new(0, 54, 0, 54)
LogoBtn.Position = UDim2.new(0, 18, 0.5, -27)
LogoBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
LogoBtn.Image = "rbxassetid://112323672996641"
LogoBtn.ScaleType = Enum.ScaleType.Fit
LogoBtn.Active = true
LogoBtn.Parent = ScreenGui

Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1, 0)

local LogoStroke = Instance.new("UIStroke", LogoBtn)
LogoStroke.Color = Color3.fromRGB(80, 140, 255)
LogoStroke.Thickness = 2
LogoStroke.Transparency = 0.15

-- Drag Logo
local draggingLogo, dragStartLogo, startPosLogo = false, nil, nil

local function isInsideLogo(pos)
	local p, s = LogoBtn.AbsolutePosition, LogoBtn.AbsoluteSize
	return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

UserInputService.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isInsideLogo(input.Position) then
		draggingLogo = true
		dragStartLogo = input.Position
		startPosLogo = LogoBtn.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingLogo = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingLogo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartLogo
		LogoBtn.Position = UDim2.new(startPosLogo.X.Scale, startPosLogo.X.Offset + delta.X, startPosLogo.Y.Scale, startPosLogo.Y.Offset + delta.Y)
	end
end)

-- ======================
-- MAIN MENU
-- ======================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 380)
Main.Position = UDim2.new(0.5, -160, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(55, 55, 75)
MainStroke.Thickness = 1.5

local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = 0.8

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KBBI Word Finder"
Title.TextColor3 = Color3.fromRGB(240, 240, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -37, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 55)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -28, 0, 38)
SearchBox.Position = UDim2.new(0, 14, 0, 56)
SearchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
SearchBox.TextColor3 = Color3.fromRGB(230, 230, 240)
SearchBox.PlaceholderText = "Waiting for input..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 15
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Main
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

local SearchStroke = Instance.new("UIStroke", SearchBox)
SearchStroke.Color = Color3.fromRGB(60, 60, 80)
SearchStroke.Thickness = 1.2

-- Results ScrollingFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -28, 1, -110)
Scroll.Position = UDim2.new(0, 14, 0, 105)
Scroll.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 10)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = Scroll

-- ======================
-- FILTER FUNCTION
-- ======================
local function updateResults(input)
	for _, child in ipairs(Scroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	input = string.lower(input or "")
	if input == "" then
		Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		return
	end

	local hasil = {}
	for _, kata in ipairs(kbbiWords) do
		if string.sub(string.lower(kata), 1, #input) == input then
			table.insert(hasil, kata)
		end
	end

	for _, kata in ipairs(hasil) do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -8, 0, 32)
		label.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
		label.TextColor3 = Color3.fromRGB(220, 220, 235)
		label.Text = "  " .. kata
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = Scroll
		Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
	end

	Scroll.CanvasSize = UDim2.new(0, 0, 0, #hasil * 37)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateResults(SearchBox.Text)
end)

-- ======================
-- OPEN / CLOSE ANIMATION
-- ======================
local menuOpen = false

local function ToggleMenu()
	menuOpen = not menuOpen

	if menuOpen then
		Main.Visible = true
		MainScale.Scale = 0.8
		Main.BackgroundTransparency = 1

		TweenService:Create(MainScale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
		TweenService:Create(Main, TweenInfo.new(0.22), {BackgroundTransparency = 0}):Play()
	else
		TweenService:Create(MainScale, TweenInfo.new(0.18), {Scale = 0.8}):Play()
		local fade = TweenService:Create(Main, TweenInfo.new(0.16), {BackgroundTransparency = 1})
		fade:Play()
		fade.Completed:Connect(function()
			if not menuOpen then
				Main.Visible = false
				Main.BackgroundTransparency = 0
			end
		end)
	end
end

LogoBtn.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		ToggleMenu()
	end
end)

print("KBBI Word Finder | Huruf A Loaded")
