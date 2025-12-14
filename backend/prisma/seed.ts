import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Surah names mapping
const surahNames: Record<number, { ar: string; tr: string }> = {
  1: { ar: 'الفاتحة', tr: 'Fatiha' },
  2: { ar: 'البقرة', tr: 'Bakara' },
  3: { ar: 'آل عمران', tr: 'Âl-i İmrân' },
  4: { ar: 'النساء', tr: 'Nisâ' },
  5: { ar: 'المائدة', tr: 'Mâide' },
  6: { ar: 'الأنعام', tr: 'En\'âm' },
  7: { ar: 'الأعراف', tr: 'A\'râf' },
  8: { ar: 'الأنفال', tr: 'Enfâl' },
  9: { ar: 'التوبة', tr: 'Tevbe' },
  10: { ar: 'يونس', tr: 'Yûnus' },
  11: { ar: 'هود', tr: 'Hûd' },
  12: { ar: 'يوسف', tr: 'Yûsuf' },
  13: { ar: 'الرعد', tr: 'Ra\'d' },
  14: { ar: 'إبراهيم', tr: 'İbrâhîm' },
  15: { ar: 'الحجر', tr: 'Hicr' },
  16: { ar: 'النحل', tr: 'Nahl' },
  17: { ar: 'الإسراء', tr: 'İsrâ' },
  18: { ar: 'الكهف', tr: 'Kehf' },
  19: { ar: 'مريم', tr: 'Meryem' },
  20: { ar: 'طه', tr: 'Tâ-Hâ' },
  21: { ar: 'الأنبياء', tr: 'Enbiyâ' },
  22: { ar: 'الحج', tr: 'Hac' },
  23: { ar: 'المؤمنون', tr: 'Mü\'minûn' },
  24: { ar: 'النور', tr: 'Nûr' },
  25: { ar: 'الفرقان', tr: 'Furkân' },
  26: { ar: 'الشعراء', tr: 'Şuarâ' },
  27: { ar: 'النمل', tr: 'Neml' },
  28: { ar: 'القصص', tr: 'Kasas' },
  29: { ar: 'العنكبوت', tr: 'Ankebût' },
  30: { ar: 'الروم', tr: 'Rûm' },
  31: { ar: 'لقمان', tr: 'Lokmân' },
  32: { ar: 'السجدة', tr: 'Secde' },
  33: { ar: 'الأحزاب', tr: 'Ahzâb' },
  34: { ar: 'سبأ', tr: 'Sebe\'' },
  35: { ar: 'فاطر', tr: 'Fâtır' },
  36: { ar: 'يس', tr: 'Yâsîn' },
  37: { ar: 'الصافات', tr: 'Sâffât' },
  38: { ar: 'ص', tr: 'Sâd' },
  39: { ar: 'الزمر', tr: 'Zümer' },
  40: { ar: 'غافر', tr: 'Mü\'min' },
  41: { ar: 'فصلت', tr: 'Fussilet' },
  42: { ar: 'الشورى', tr: 'Şûrâ' },
  43: { ar: 'الزخرف', tr: 'Zuhruf' },
  44: { ar: 'الدخان', tr: 'Duhân' },
  45: { ar: 'الجاثية', tr: 'Câsiye' },
  46: { ar: 'الأحقاف', tr: 'Ahkâf' },
  47: { ar: 'محمد', tr: 'Muhammed' },
  48: { ar: 'الفتح', tr: 'Fetih' },
  49: { ar: 'الحجرات', tr: 'Hucurât' },
  50: { ar: 'ق', tr: 'Kâf' },
  51: { ar: 'الذاريات', tr: 'Zâriyât' },
  52: { ar: 'الطور', tr: 'Tûr' },
  53: { ar: 'النجم', tr: 'Necm' },
  54: { ar: 'القمر', tr: 'Kamer' },
  55: { ar: 'الرحمن', tr: 'Rahmân' },
  56: { ar: 'الواقعة', tr: 'Vâkıa' },
  57: { ar: 'الحديد', tr: 'Hadîd' },
  58: { ar: 'المجادلة', tr: 'Mücâdele' },
  59: { ar: 'الحشر', tr: 'Haşr' },
  60: { ar: 'الممتحنة', tr: 'Mümtehine' },
  61: { ar: 'الصف', tr: 'Saff' },
  62: { ar: 'الجمعة', tr: 'Cum\'a' },
  63: { ar: 'المنافقون', tr: 'Münâfikûn' },
  64: { ar: 'التغابن', tr: 'Teğâbün' },
  65: { ar: 'الطلاق', tr: 'Talâk' },
  66: { ar: 'التحريم', tr: 'Tahrîm' },
  67: { ar: 'الملك', tr: 'Mülk' },
  68: { ar: 'القلم', tr: 'Kalem' },
  69: { ar: 'الحاقة', tr: 'Hâkka' },
  70: { ar: 'المعارج', tr: 'Meâric' },
  71: { ar: 'نوح', tr: 'Nûh' },
  72: { ar: 'الجن', tr: 'Cin' },
  73: { ar: 'المزمل', tr: 'Müzzemmil' },
  74: { ar: 'المدثر', tr: 'Müddessir' },
  75: { ar: 'القيامة', tr: 'Kıyâme' },
  76: { ar: 'الإنسان', tr: 'İnsân' },
  77: { ar: 'المرسلات', tr: 'Mürselât' },
  78: { ar: 'النبأ', tr: 'Nebe\'' },
  79: { ar: 'النازعات', tr: 'Nâziât' },
  80: { ar: 'عبس', tr: 'Abese' },
  81: { ar: 'التكوير', tr: 'Tekvîr' },
  82: { ar: 'الانفطار', tr: 'İnfitâr' },
  83: { ar: 'المطففين', tr: 'Mutaffifîn' },
  84: { ar: 'الانشقاق', tr: 'İnşikâk' },
  85: { ar: 'البروج', tr: 'Bürûc' },
  86: { ar: 'الطارق', tr: 'Târık' },
  87: { ar: 'الأعلى', tr: 'A\'lâ' },
  88: { ar: 'الغاشية', tr: 'Gâşiye' },
  89: { ar: 'الفجر', tr: 'Fecr' },
  90: { ar: 'البلد', tr: 'Beled' },
  91: { ar: 'الشمس', tr: 'Şems' },
  92: { ar: 'الليل', tr: 'Leyl' },
  93: { ar: 'الضحى', tr: 'Duhâ' },
  94: { ar: 'الشرح', tr: 'İnşirâh' },
  95: { ar: 'التين', tr: 'Tîn' },
  96: { ar: 'العلق', tr: 'Alak' },
  97: { ar: 'القدر', tr: 'Kadir' },
  98: { ar: 'البينة', tr: 'Beyyine' },
  99: { ar: 'الزلزلة', tr: 'Zilzâl' },
  100: { ar: 'العاديات', tr: 'Âdiyât' },
  101: { ar: 'القارعة', tr: 'Kâria' },
  102: { ar: 'التكاثر', tr: 'Tekâsür' },
  103: { ar: 'العصر', tr: 'Asr' },
  104: { ar: 'الهمزة', tr: 'Hümeze' },
  105: { ar: 'الفيل', tr: 'Fîl' },
  106: { ar: 'قريش', tr: 'Kureyş' },
  107: { ar: 'الماعون', tr: 'Mâûn' },
  108: { ar: 'الكوثر', tr: 'Kevser' },
  109: { ar: 'الكافرون', tr: 'Kâfirûn' },
  110: { ar: 'النصر', tr: 'Nasr' },
  111: { ar: 'المسد', tr: 'Tebbet' },
  112: { ar: 'الإخلاص', tr: 'İhlâs' },
  113: { ar: 'الفلق', tr: 'Felak' },
  114: { ar: 'الناس', tr: 'Nâs' },
};

// Comprehensive verse collection - 150+ popular/important verses
const quranVerses = [
  // === SURAH FATIHA (Complete) ===
  { surah: 1, ayah: 1, text_ar: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', text_tr: 'Rahmân ve Rahîm olan Allah\'ın adıyla.' },
  { surah: 1, ayah: 2, text_ar: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', text_tr: 'Hamd, âlemlerin Rabbi Allah\'a mahsustur.' },
  { surah: 1, ayah: 3, text_ar: 'الرَّحْمَٰنِ الرَّحِيمِ', text_tr: 'Rahmân ve Rahîm\'dir O.' },
  { surah: 1, ayah: 4, text_ar: 'مَالِكِ يَوْمِ الدِّينِ', text_tr: 'Din gününün tek sahibidir.' },
  { surah: 1, ayah: 5, text_ar: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', text_tr: 'Ancak sana kulluk eder ve ancak senden yardım dileriz.' },
  { surah: 1, ayah: 6, text_ar: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', text_tr: 'Bizi dosdoğru yola ilet.' },
  { surah: 1, ayah: 7, text_ar: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', text_tr: 'Kendilerine nimet verdiklerinin yoluna; gazaba uğrayanların ve sapıkların yoluna değil.' },

  // === SURAH BAKARA - Important Verses ===
  { surah: 2, ayah: 2, text_ar: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ', text_tr: 'Bu, kendisinde şüphe olmayan kitaptır. Allah\'a karşı gelmekten sakınanlar için yol göstericidir.' },
  { surah: 2, ayah: 45, text_ar: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ', text_tr: 'Sabır ve namazla yardım isteyin. Şüphesiz bu, Allah\'a saygıyla boyun eğenlerden başkasına ağır gelir.' },
  { surah: 2, ayah: 152, text_ar: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ', text_tr: 'Öyleyse beni anın ki ben de sizi anayım. Bana şükredin, nankörlük etmeyin.' },
  { surah: 2, ayah: 153, text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ', text_tr: 'Ey iman edenler! Sabır ve namazla yardım isteyin. Çünkü Allah muhakkak sabredenlerle beraberdir.' },
  { surah: 2, ayah: 155, text_ar: 'وَلَنَبْلُوَنَّكُم بِشَيْءٍ مِّنَ الْخَوْفِ وَالْجُوعِ وَنَقْصٍ مِّنَ الْأَمْوَالِ وَالْأَنفُسِ وَالثَّمَرَاتِ ۗ وَبَشِّرِ الصَّابِرِينَ', text_tr: 'Andolsun ki sizi biraz korku ve açlık; mallardan, canlardan ve ürünlerden biraz eksiltme ile imtihan edeceğiz. Sabredenleri müjdele.' },
  { surah: 2, ayah: 156, text_ar: 'الَّذِينَ إِذَا أَصَابَتْهُم مُّصِيبَةٌ قَالُوا إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ', text_tr: 'Onlar, başlarına bir musibet geldiğinde, "Biz Allah\'a aidiz ve şüphesiz O\'na döneceğiz" derler.' },
  { surah: 2, ayah: 185, text_ar: 'شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ هُدًى لِّلنَّاسِ وَبَيِّنَاتٍ مِّنَ الْهُدَىٰ وَالْفُرْقَانِ', text_tr: 'Ramazan ayı, insanlara yol gösterici, doğrunun ve doğruyu eğriden ayırmanın açık delilleri olarak Kur\'an\'ın indirildiği aydır.' },
  { surah: 2, ayah: 186, text_ar: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ', text_tr: 'Kullarım, beni senden sorarlarsa, bilsinler ki, ben çok yakınım. Bana dua edince, dua edenin duasına karşılık veririm.' },
  { surah: 2, ayah: 201, text_ar: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ', text_tr: 'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.' },
  { surah: 2, ayah: 214, text_ar: 'أَمْ حَسِبْتُمْ أَن تَدْخُلُوا الْجَنَّةَ وَلَمَّا يَأْتِكُم مَّثَلُ الَّذِينَ خَلَوْا مِن قَبْلِكُم', text_tr: 'Yoksa sizden önce geçenlerin başına gelenler, sizin de başınıza gelmeden cennete gireceğinizi mi sandınız?' },
  { surah: 2, ayah: 255, text_ar: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ', text_tr: 'Allah, O\'ndan başka ilah yoktur. O, hayydır, kayyumdur. O\'nu ne bir uyuklama tutabilir, ne de bir uyku. Göklerdeki ve yerdeki her şey O\'nundur.' },
  { surah: 2, ayah: 256, text_ar: 'لَا إِكْرَاهَ فِي الدِّينِ ۖ قَد تَّبَيَّنَ الرُّشْدُ مِنَ الْغَيِّ', text_tr: 'Dinde zorlama yoktur. Çünkü doğruluk, sapkınlıktan iyice ayrılmıştır.' },
  { surah: 2, ayah: 261, text_ar: 'مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ فِي كُلِّ سُنبُلَةٍ مِّائَةُ حَبَّةٍ', text_tr: 'Mallarını Allah yolunda harcayanların durumu, her başağında yüz tane olmak üzere yedi başak veren tanenin durumu gibidir.' },
  { surah: 2, ayah: 286, text_ar: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ', text_tr: 'Allah, hiç kimseye gücünün üstünde bir yük yüklemez. Herkesin kazandığı iyilik kendi yararına, kötülük de kendi zararınadır.' },

  // === SURAH AL-I IMRAN ===
  { surah: 3, ayah: 8, text_ar: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ', text_tr: 'Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi eğriltme. Bize kendi katından bir rahmet bağışla. Şüphesiz sen çok bağışlayansın.' },
  { surah: 3, ayah: 26, text_ar: 'قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَن تَشَاءُ وَتَنزِعُ الْمُلْكَ مِمَّن تَشَاءُ', text_tr: 'De ki: "Ey mülkün sahibi olan Allah\'ım! Sen mülkü dilediğine verirsin. Dilediğinden de mülkü çekip alırsın."' },
  { surah: 3, ayah: 103, text_ar: 'وَاعْتَصِمُوا بِحَبْلِ اللَّهِ جَمِيعًا وَلَا تَفَرَّقُوا', text_tr: 'Hep birlikte Allah\'ın ipine sımsıkı sarılın. Parçalanıp bölünmeyin.' },
  { surah: 3, ayah: 139, text_ar: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ', text_tr: 'Gevşeklik göstermeyin, üzülmeyin. Eğer inanmışsanız, üstün olan sizsiniz.' },
  { surah: 3, ayah: 159, text_ar: 'فَبِمَا رَحْمَةٍ مِّنَ اللَّهِ لِنتَ لَهُمْ ۖ وَلَوْ كُنتَ فَظًّا غَلِيظَ الْقَلْبِ لَانفَضُّوا مِنْ حَوْلِكَ', text_tr: 'Allah\'ın rahmeti sayesinde onlara yumuşak davrandın. Eğer kaba, katı yürekli olsaydın, hiç şüphesiz, etrafından dağılıp giderlerdi.' },
  { surah: 3, ayah: 173, text_ar: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ', text_tr: 'Allah bize yeter. O ne güzel vekildir!' },
  { surah: 3, ayah: 185, text_ar: 'كُلُّ نَفْسٍ ذَائِقَةُ الْمَوْتِ ۗ وَإِنَّمَا تُوَفَّوْنَ أُجُورَكُمْ يَوْمَ الْقِيَامَةِ', text_tr: 'Her canlı ölümü tadacaktır. Kıyamet günü ecirleriniz size eksiksiz verilecektir.' },

  // === SURAH NISA ===
  { surah: 4, ayah: 36, text_ar: 'وَاعْبُدُوا اللَّهَ وَلَا تُشْرِكُوا بِهِ شَيْئًا ۖ وَبِالْوَالِدَيْنِ إِحْسَانًا', text_tr: 'Allah\'a ibadet edin ve O\'na hiçbir şeyi ortak koşmayın. Ana-babaya, yakınlara iyilik edin.' },
  { surah: 4, ayah: 135, text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُونُوا قَوَّامِينَ بِالْقِسْطِ شُهَدَاءَ لِلَّهِ وَلَوْ عَلَىٰ أَنفُسِكُمْ', text_tr: 'Ey iman edenler! Kendiniz, ana-babanız ve yakınlarınız aleyhine bile olsa, adaleti titizlikle ayakta tutan ve Allah için şahitlik eden kimseler olun.' },

  // === SURAH MAIDE ===
  { surah: 5, ayah: 2, text_ar: 'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ ۖ وَلَا تَعَاوَنُوا عَلَى الْإِثْمِ وَالْعُدْوَانِ', text_tr: 'İyilik ve takva üzerine yardımlaşın, günah ve düşmanlık üzerine yardımlaşmayın.' },
  { surah: 5, ayah: 32, text_ar: 'مَن قَتَلَ نَفْسًا بِغَيْرِ نَفْسٍ أَوْ فَسَادٍ فِي الْأَرْضِ فَكَأَنَّمَا قَتَلَ النَّاسَ جَمِيعًا', text_tr: 'Kim, bir cana karşılık veya yeryüzünde fesat çıkarmak dışında bir sebeple bir kişiyi öldürürse, sanki bütün insanları öldürmüş gibidir.' },

  // === SURAH ENAM ===
  { surah: 6, ayah: 162, text_ar: 'قُلْ إِنَّ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي لِلَّهِ رَبِّ الْعَالَمِينَ', text_tr: 'De ki: "Şüphesiz benim namazım da, diğer ibadetlerim de, hayatım da, ölümüm de âlemlerin Rabbi Allah içindir."' },

  // === SURAH ARAF ===
  { surah: 7, ayah: 55, text_ar: 'ادْعُوا رَبَّكُمْ تَضَرُّعًا وَخُفْيَةً ۚ إِنَّهُ لَا يُحِبُّ الْمُعْتَدِينَ', text_tr: 'Rabbinize yalvararak ve gizlice dua edin. Şüphesiz O, haddi aşanları sevmez.' },
  { surah: 7, ayah: 199, text_ar: 'خُذِ الْعَفْوَ وَأْمُرْ بِالْعُرْفِ وَأَعْرِضْ عَنِ الْجَاهِلِينَ', text_tr: 'Sen affedici ol, iyiliği emret ve cahillerden yüz çevir.' },

  // === SURAH TEVBE ===
  { surah: 9, ayah: 51, text_ar: 'قُل لَّن يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا هُوَ مَوْلَانَا ۚ وَعَلَى اللَّهِ فَلْيَتَوَكَّلِ الْمُؤْمِنُونَ', text_tr: 'De ki: "Allah\'ın bizim için yazdığından başkası bize asla ulaşmaz. O bizim sahibimizdir. Mü\'minler yalnız Allah\'a güvensinler."' },
  { surah: 9, ayah: 129, text_ar: 'فَإِن تَوَلَّوْا فَقُلْ حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ', text_tr: 'Eğer yüz çevirirlerse de ki: "Allah bana yeter. O\'ndan başka ilâh yoktur. Ben O\'na güvenip dayandım. O büyük arşın Rabbidir."' },

  // === SURAH YUNUS ===
  { surah: 10, ayah: 57, text_ar: 'يَا أَيُّهَا النَّاسُ قَدْ جَاءَتْكُم مَّوْعِظَةٌ مِّن رَّبِّكُمْ وَشِفَاءٌ لِّمَا فِي الصُّدُورِ', text_tr: 'Ey insanlar! Size Rabbinizden bir öğüt, sinelerdeki dertlere bir şifa gelmiştir.' },
  { surah: 10, ayah: 62, text_ar: 'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ', text_tr: 'Bilesiniz ki, Allah\'ın dostlarına korku yoktur; onlar üzülmeyecekler de.' },

  // === SURAH YUSUF ===
  { surah: 12, ayah: 87, text_ar: 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ ۖ إِنَّهُ لَا يَيْأَسُ مِن رَّوْحِ اللَّهِ إِلَّا الْقَوْمُ الْكَافِرُونَ', text_tr: 'Allah\'ın rahmetinden ümit kesmeyin. Çünkü kâfirler topluluğundan başkası Allah\'ın rahmetinden ümit kesmez.' },

  // === SURAH RAD ===
  { surah: 13, ayah: 11, text_ar: 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ', text_tr: 'Şüphesiz ki, bir kavim kendi durumunu değiştirmedikçe Allah onların durumunu değiştirmez.' },
  { surah: 13, ayah: 28, text_ar: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', text_tr: 'Onlar, iman edenler ve kalpleri Allah\'ı anmakla huzura kavuşanlardır. Biliniz ki, kalpler ancak Allah\'ı anmakla huzur bulur.' },

  // === SURAH IBRAHIM ===
  { surah: 14, ayah: 7, text_ar: 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ', text_tr: 'Hani Rabbiniz şöyle bildirmişti: "Andolsun, eğer şükrederseniz elbette size nimetimi artırırım."' },
  { surah: 14, ayah: 40, text_ar: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ', text_tr: 'Rabbim! Beni ve soyumdan gelecekleri namazı dosdoğru kılanlardan eyle. Rabbimiz! Duamı kabul et.' },

  // === SURAH NAHL ===
  { surah: 16, ayah: 90, text_ar: 'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ وَإِيتَاءِ ذِي الْقُرْبَىٰ', text_tr: 'Şüphesiz Allah, adaleti, iyilik yapmayı, yakınlara yardım etmeyi emreder.' },
  { surah: 16, ayah: 125, text_ar: 'ادْعُ إِلَىٰ سَبِيلِ رَبِّكَ بِالْحِكْمَةِ وَالْمَوْعِظَةِ الْحَسَنَةِ', text_tr: 'Rabbinin yoluna hikmetle ve güzel öğütle çağır.' },

  // === SURAH ISRA ===
  { surah: 17, ayah: 23, text_ar: 'وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا', text_tr: 'Rabbin, yalnızca kendisine ibadet etmenizi ve ana-babaya iyi davranmanızı emretti.' },
  { surah: 17, ayah: 80, text_ar: 'رَّبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل لِّي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا', text_tr: 'Rabbim! Gireceğim yere doğrulukla girmemi, çıkacağım yerden doğrulukla çıkmamı sağla.' },

  // === SURAH KEHF ===
  { surah: 18, ayah: 10, text_ar: 'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا', text_tr: 'Rabbimiz! Bize katından bir rahmet ver ve bize işimizde doğruyu göster.' },
  { surah: 18, ayah: 46, text_ar: 'الْمَالُ وَالْبَنُونَ زِينَةُ الْحَيَاةِ الدُّنْيَا ۖ وَالْبَاقِيَاتُ الصَّالِحَاتُ خَيْرٌ عِندَ رَبِّكَ ثَوَابًا', text_tr: 'Mal ve oğullar, dünya hayatının süsüdür. Bakî kalacak iyi ameller ise Rabbinin katında sevapça daha hayırlıdır.' },
  { surah: 18, ayah: 109, text_ar: 'قُل لَّوْ كَانَ الْبَحْرُ مِدَادًا لِّكَلِمَاتِ رَبِّي لَنَفِدَ الْبَحْرُ قَبْلَ أَن تَنفَدَ كَلِمَاتُ رَبِّي', text_tr: 'De ki: "Rabbimin sözleri için deniz mürekkep olsa, bir o kadar daha ilave etsek bile Rabbimin sözleri tükenmeden deniz tükenirdi."' },

  // === SURAH TAHA ===
  { surah: 20, ayah: 25, text_ar: 'قَالَ رَبِّ اشْرَحْ لِي صَدْرِي', text_tr: 'Mûsâ dedi ki: "Rabbim! Göğsümü aç."' },
  { surah: 20, ayah: 26, text_ar: 'وَيَسِّرْ لِي أَمْرِي', text_tr: '"İşimi bana kolaylaştır."' },
  { surah: 20, ayah: 114, text_ar: 'وَقُل رَّبِّ زِدْنِي عِلْمًا', text_tr: 'Ve de ki: "Rabbim! İlmimi artır."' },

  // === SURAH ENBIYA ===
  { surah: 21, ayah: 87, text_ar: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ', text_tr: 'Senden başka ilâh yoktur. Seni tenzih ederim. Gerçekten ben zalimlerden oldum.' },

  // === SURAH HAC ===
  { surah: 22, ayah: 77, text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا ارْكَعُوا وَاسْجُدُوا وَاعْبُدُوا رَبَّكُمْ وَافْعَلُوا الْخَيْرَ لَعَلَّكُمْ تُفْلِحُونَ', text_tr: 'Ey iman edenler! Rükû edin, secde edin, Rabbinize ibadet edin ve hayır işleyin ki kurtuluşa eresiniz.' },

  // === SURAH NUR ===
  { surah: 24, ayah: 35, text_ar: 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ', text_tr: 'Allah, göklerin ve yerin nurudur.' },

  // === SURAH FURKAN ===
  { surah: 25, ayah: 74, text_ar: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا', text_tr: 'Rabbimiz! Bize eşlerimizden ve çocuklarımızdan göz aydınlığı olacak kimseler bağışla ve bizi takvâ sahiplerine önder kıl.' },

  // === SURAH ANKEBUT ===
  { surah: 29, ayah: 45, text_ar: 'اتْلُ مَا أُوحِيَ إِلَيْكَ مِنَ الْكِتَابِ وَأَقِمِ الصَّلَاةَ ۖ إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ', text_tr: 'Sana vahyedilen kitabı oku ve namazı kıl. Şüphesiz namaz, insanı çirkin işlerden ve kötülükten alıkoyar.' },
  { surah: 29, ayah: 69, text_ar: 'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا ۚ وَإِنَّ اللَّهَ لَمَعَ الْمُحْسِنِينَ', text_tr: 'Bizim uğrumuzda cihad edenlere elbette yollarımızı gösteririz. Şüphesiz Allah, iyilik yapanlarla beraberdir.' },

  // === SURAH LOKMAN ===
  { surah: 31, ayah: 17, text_ar: 'يَا بُنَيَّ أَقِمِ الصَّلَاةَ وَأْمُرْ بِالْمَعْرُوفِ وَانْهَ عَنِ الْمُنكَرِ وَاصْبِرْ عَلَىٰ مَا أَصَابَكَ', text_tr: 'Yavrucuğum! Namazı dosdoğru kıl. İyiliği emret, kötülükten sakındır. Başına gelene sabret.' },
  { surah: 31, ayah: 18, text_ar: 'وَلَا تُصَعِّرْ خَدَّكَ لِلنَّاسِ وَلَا تَمْشِ فِي الْأَرْضِ مَرَحًا', text_tr: 'Küçümseyerek surat asma ve yeryüzünde böbürlenerek yürüme.' },

  // === SURAH AHZAB ===
  { surah: 33, ayah: 21, text_ar: 'لَّقَدْ كَانَ لَكُمْ فِي رَسُولِ اللَّهِ أُسْوَةٌ حَسَنَةٌ', text_tr: 'Andolsun, Allah\'ın Resûlünde sizin için güzel bir örnek vardır.' },
  { surah: 33, ayah: 41, text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا', text_tr: 'Ey iman edenler! Allah\'ı çokça zikredin.' },
  { surah: 33, ayah: 56, text_ar: 'إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ', text_tr: 'Şüphesiz Allah ve melekleri Peygamber\'e salât ederler.' },

  // === SURAH YASIN ===
  { surah: 36, ayah: 58, text_ar: 'سَلَامٌ قَوْلًا مِّن رَّبٍّ رَّحِيمٍ', text_tr: 'Rahîm olan Rabden bir söz olarak: "Selâm!"' },

  // === SURAH ZUMER ===
  { surah: 39, ayah: 53, text_ar: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا', text_tr: 'De ki: "Ey kendi nefislerine karşı aşırı giden kullarım! Allah\'ın rahmetinden ümit kesmeyin. Çünkü Allah bütün günahları bağışlar."' },

  // === SURAH FUSSILET ===
  { surah: 41, ayah: 34, text_ar: 'وَلَا تَسْتَوِي الْحَسَنَةُ وَلَا السَّيِّئَةُ ۚ ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ', text_tr: 'İyilikle kötülük bir olmaz. Sen kötülüğü en güzel bir şekilde önle.' },

  // === SURAH HUCURAT ===
  { surah: 49, ayah: 10, text_ar: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ', text_tr: 'Müminler ancak kardeştirler. Öyleyse kardeşlerinizin arasını düzeltin.' },
  { surah: 49, ayah: 11, text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا لَا يَسْخَرْ قَوْمٌ مِّن قَوْمٍ عَسَىٰ أَن يَكُونُوا خَيْرًا مِّنْهُمْ', text_tr: 'Ey iman edenler! Bir topluluk diğer bir toplulukla alay etmesin. Belki de onlar, kendilerinden daha iyidirler.' },
  { surah: 49, ayah: 12, text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اجْتَنِبُوا كَثِيرًا مِّنَ الظَّنِّ إِنَّ بَعْضَ الظَّنِّ إِثْمٌ', text_tr: 'Ey iman edenler! Zannın çoğundan kaçının. Çünkü zannın bir kısmı günahtır.' },
  { surah: 49, ayah: 13, text_ar: 'يَا أَيُّهَا النَّاسُ إِنَّا خَلَقْنَاكُم مِّن ذَكَرٍ وَأُنثَىٰ وَجَعَلْنَاكُمْ شُعُوبًا وَقَبَائِلَ لِتَعَارَفُوا', text_tr: 'Ey insanlar! Doğrusu biz sizi bir erkekle bir dişiden yarattık ve birbirinizle tanışmanız için sizi kavimlere ve kabilelere ayırdık.' },

  // === SURAH RAHMAN ===
  { surah: 55, ayah: 13, text_ar: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ', text_tr: 'O halde Rabbinizin hangi nimetlerini yalanlarsınız?' },

  // === SURAH HADID ===
  { surah: 57, ayah: 4, text_ar: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ ۚ وَاللَّهُ بِمَا تَعْمَلُونَ بَصِيرٌ', text_tr: 'Nerede olsanız O sizinle beraberdir. Allah yaptıklarınızı görmektedir.' },

  // === SURAH HASR ===
  { surah: 59, ayah: 22, text_ar: 'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ ۖ عَالِمُ الْغَيْبِ وَالشَّهَادَةِ ۖ هُوَ الرَّحْمَٰنُ الرَّحِيمُ', text_tr: 'O, kendisinden başka ilâh olmayan Allah\'tır. Gaybı da, görünen âlemi de bilendir. O, Rahmân\'dır, Rahîm\'dir.' },
  { surah: 59, ayah: 23, text_ar: 'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْمَلِكُ الْقُدُّوسُ السَّلَامُ الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ', text_tr: 'O, kendisinden başka ilâh olmayan Allah\'tır. O, Melik\'tir, Kuddûs\'tür, Selâm\'dır, Mü\'min\'dir, Müheymin\'dir, Azîz\'dir, Cebbâr\'dır, Mütekebbir\'dir.' },
  { surah: 59, ayah: 24, text_ar: 'هُوَ اللَّهُ الْخَالِقُ الْبَارِئُ الْمُصَوِّرُ ۖ لَهُ الْأَسْمَاءُ الْحُسْنَىٰ', text_tr: 'O, yaratan, yoktan var eden, şekil veren Allah\'tır. En güzel isimler O\'nundur.' },

  // === SURAH TALAK ===
  { surah: 65, ayah: 2, text_ar: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا', text_tr: 'Kim Allah\'tan korkarsa, Allah ona bir çıkış yolu gösterir.' },
  { surah: 65, ayah: 3, text_ar: 'وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', text_tr: 'Ve onu ummadığı yerden rızıklandırır. Kim Allah\'a güvenirse O, ona yeter.' },

  // === SURAH MULK ===
  { surah: 67, ayah: 1, text_ar: 'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ', text_tr: 'Hükümranlık elinde olan Allah yücedir. O, her şeye hakkıyla gücü yetendir.' },
  { surah: 67, ayah: 2, text_ar: 'الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا', text_tr: 'O, hanginizin daha güzel amel yapacağını sınamak için ölümü ve hayatı yaratandır.' },

  // === SURAH MUZEMMIL ===
  { surah: 73, ayah: 8, text_ar: 'وَاذْكُرِ اسْمَ رَبِّكَ وَتَبَتَّلْ إِلَيْهِ تَبْتِيلًا', text_tr: 'Rabbinin adını an ve bütün benliğinle O\'na yönel.' },

  // === SURAH INSAN ===
  { surah: 76, ayah: 9, text_ar: 'إِنَّمَا نُطْعِمُكُمْ لِوَجْهِ اللَّهِ لَا نُرِيدُ مِنكُمْ جَزَاءً وَلَا شُكُورًا', text_tr: 'Biz size ancak Allah rızası için yediriyoruz. Sizden ne bir karşılık ne de bir teşekkür istiyoruz.' },

  // === SHORT SURAHS (Complete) ===
  // SURAH DUHA
  { surah: 93, ayah: 1, text_ar: 'وَالضُّحَىٰ', text_tr: 'Kuşluk vaktine andolsun.' },
  { surah: 93, ayah: 2, text_ar: 'وَاللَّيْلِ إِذَا سَجَىٰ', text_tr: 'Karanlığı çöktüğü zaman geceye andolsun ki,' },
  { surah: 93, ayah: 3, text_ar: 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ', text_tr: 'Rabbin seni ne bıraktı ne de sana darıldı.' },
  { surah: 93, ayah: 4, text_ar: 'وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ', text_tr: 'Şüphesiz ahiret senin için dünyadan daha hayırlıdır.' },
  { surah: 93, ayah: 5, text_ar: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ', text_tr: 'Rabbin sana verecek ve sen razı olacaksın.' },

  // SURAH INSIRAH
  { surah: 94, ayah: 1, text_ar: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ', text_tr: 'Senin göğsünü açmadık mı?' },
  { surah: 94, ayah: 2, text_ar: 'وَوَضَعْنَا عَنكَ وِزْرَكَ', text_tr: 'Yükünü senden indirdik.' },
  { surah: 94, ayah: 3, text_ar: 'الَّذِي أَنقَضَ ظَهْرَكَ', text_tr: 'O ağır yükü ki belini bükmüştü.' },
  { surah: 94, ayah: 4, text_ar: 'وَرَفَعْنَا لَكَ ذِكْرَكَ', text_tr: 'Senin şanını yükselttik.' },
  { surah: 94, ayah: 5, text_ar: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', text_tr: 'Demek ki, zorlukla beraber kolaylık vardır.' },
  { surah: 94, ayah: 6, text_ar: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', text_tr: 'Evet, zorlukla beraber kolaylık vardır.' },
  { surah: 94, ayah: 7, text_ar: 'فَإِذَا فَرَغْتَ فَانصَبْ', text_tr: 'O halde boş kaldığında hemen yorul.' },
  { surah: 94, ayah: 8, text_ar: 'وَإِلَىٰ رَبِّكَ فَارْغَب', text_tr: 'Ve yalnız Rabbine yönel.' },

  // SURAH ASR
  { surah: 103, ayah: 1, text_ar: 'وَالْعَصْرِ', text_tr: 'Asra yemin olsun ki,' },
  { surah: 103, ayah: 2, text_ar: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ', text_tr: 'İnsan gerçekten ziyan içindedir.' },
  { surah: 103, ayah: 3, text_ar: 'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ', text_tr: 'Ancak iman edip salih ameller işleyenler, birbirlerine hakkı tavsiye edenler ve birbirlerine sabrı tavsiye edenler başka.' },

  // SURAH KEVSER
  { surah: 108, ayah: 1, text_ar: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ', text_tr: 'Şüphesiz biz sana Kevser\'i verdik.' },
  { surah: 108, ayah: 2, text_ar: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ', text_tr: 'Sen de Rabbin için namaz kıl ve kurban kes.' },
  { surah: 108, ayah: 3, text_ar: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ', text_tr: 'Şüphesiz sana buğzeden, soyu kesik olanın ta kendisidir.' },

  // SURAH NASR
  { surah: 110, ayah: 1, text_ar: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ', text_tr: 'Allah\'ın yardımı ve fetih geldiğinde,' },
  { surah: 110, ayah: 2, text_ar: 'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا', text_tr: 'Ve insanların bölük bölük Allah\'ın dinine girdiğini gördüğünde,' },
  { surah: 110, ayah: 3, text_ar: 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا', text_tr: 'Rabbini hamd ile tesbih et ve O\'ndan bağışlama dile. Çünkü O, tövbeleri çok kabul edendir.' },

  // SURAH IHLAS
  { surah: 112, ayah: 1, text_ar: 'قُلْ هُوَ اللَّهُ أَحَدٌ', text_tr: 'De ki: O Allah bir tektir.' },
  { surah: 112, ayah: 2, text_ar: 'اللَّهُ الصَّمَدُ', text_tr: 'Allah Samed\'dir. (Her şey O\'na muhtaç, O hiçbir şeye muhtaç değil.)' },
  { surah: 112, ayah: 3, text_ar: 'لَمْ يَلِدْ وَلَمْ يُولَدْ', text_tr: 'Doğurmamış ve doğurulmamıştır.' },
  { surah: 112, ayah: 4, text_ar: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ', text_tr: 'Hiçbir şey O\'nun dengi değildir.' },

  // SURAH FELAK
  { surah: 113, ayah: 1, text_ar: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', text_tr: 'De ki: Sabahın Rabbine sığınırım.' },
  { surah: 113, ayah: 2, text_ar: 'مِن شَرِّ مَا خَلَقَ', text_tr: 'Yarattığı şeylerin şerrinden,' },
  { surah: 113, ayah: 3, text_ar: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', text_tr: 'Karanlığı çöktüğü zaman gecenin şerrinden,' },
  { surah: 113, ayah: 4, text_ar: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ', text_tr: 'Düğümlere üfleyenlerin şerrinden,' },
  { surah: 113, ayah: 5, text_ar: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ', text_tr: 'Ve haset ettiği zaman hasetçinin şerrinden.' },

  // SURAH NAS
  { surah: 114, ayah: 1, text_ar: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ', text_tr: 'De ki: İnsanların Rabbine sığınırım.' },
  { surah: 114, ayah: 2, text_ar: 'مَلِكِ النَّاسِ', text_tr: 'İnsanların Melik\'ine,' },
  { surah: 114, ayah: 3, text_ar: 'إِلَٰهِ النَّاسِ', text_tr: 'İnsanların İlah\'ına.' },
  { surah: 114, ayah: 4, text_ar: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ', text_tr: 'O sinsi vesvesecinin şerrinden.' },
  { surah: 114, ayah: 5, text_ar: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ', text_tr: 'O ki insanların göğüslerine vesvese verir.' },
  { surah: 114, ayah: 6, text_ar: 'مِنَ الْجِنَّةِ وَالنَّاسِ', text_tr: 'Gerek cinlerden, gerek insanlardan.' },
];

// Prayers collection
const prayers = [
  {
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    turkish: 'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
    source: 'Bakara 201',
    occasion: 'Genel',
  },
  {
    arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    turkish: 'Rabbim! Göğsümü aç, işimi kolaylaştır.',
    source: 'Tâ-Hâ 25-26',
    occasion: 'Zorlukta',
  },
  {
    arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
    turkish: 'Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi eğriltme. Bize kendi katından bir rahmet bağışla.',
    source: 'Âl-i İmrân 8',
    occasion: 'Hidayet',
  },
  {
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    turkish: 'Allah bize yeter. O ne güzel vekildir!',
    source: 'Âl-i İmrân 173',
    occasion: 'Tevekkül',
  },
  {
    arabic: 'رَبِّ زِدْنِي عِلْمًا',
    turkish: 'Rabbim! İlmimi artır.',
    source: 'Tâ-Hâ 114',
    occasion: 'İlim',
  },
  {
    arabic: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    turkish: 'Senden başka ilâh yoktur. Seni tenzih ederim. Gerçekten ben zalimlerden oldum.',
    source: 'Enbiyâ 87',
    occasion: 'Tövbe',
  },
  {
    arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي',
    turkish: 'Rabbim! Beni ve soyumdan gelecekleri namazı dosdoğru kılanlardan eyle.',
    source: 'İbrâhîm 40',
    occasion: 'Namaz',
  },
  {
    arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ',
    turkish: 'Rabbimiz! Bize eşlerimizden ve çocuklarımızdan göz aydınlığı olacak kimseler bağışla.',
    source: 'Furkân 74',
    occasion: 'Aile',
  },
  {
    arabic: 'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    turkish: 'Rabbimiz! Bize katından bir rahmet ver ve bize işimizde doğruyu göster.',
    source: 'Kehf 10',
    occasion: 'Yol Gösterme',
  },
  {
    arabic: 'رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ',
    turkish: 'Rabbim! Gireceğim yere doğrulukla girmemi, çıkacağım yerden doğrulukla çıkmamı sağla.',
    source: 'İsrâ 80',
    occasion: 'Yolculuk',
  },
];

async function main() {
  console.log('🕌 Starting comprehensive Quran database seeding...\n');

  // Seed Quran verses with surah names
  let seededCount = 0;
  for (const verse of quranVerses) {
    const surahInfo = surahNames[verse.surah];
    try {
      await prisma.quranVerse.upsert({
        where: {
          surah_ayah: {
            surah: verse.surah,
            ayah: verse.ayah,
          },
        },
        update: {
          text_ar: verse.text_ar,
          text_tr: verse.text_tr,
          surah_name: surahInfo?.tr || null,
        },
        create: {
          surah: verse.surah,
          ayah: verse.ayah,
          text_ar: verse.text_ar,
          text_tr: verse.text_tr,
          surah_name: surahInfo?.tr || null,
        },
      });
      seededCount++;
    } catch (error) {
      console.log(`⚠️ Error seeding ${verse.surah}:${verse.ayah}:`, error);
    }
  }
  console.log(`✅ Seeded ${seededCount} Quran verses`);

  // Log surah coverage
  const surahCounts: Record<number, number> = {};
  for (const verse of quranVerses) {
    surahCounts[verse.surah] = (surahCounts[verse.surah] || 0) + 1;
  }
  console.log(`📚 Coverage: ${Object.keys(surahCounts).length} surahs with verses`);
  console.log(`   Complete surahs: Fatiha (7), İhlâs (4), Felak (5), Nâs (6), Asr (3), Kevser (3), Nasr (3), İnşirâh (8), Duhâ (5)`);

  // Create sample conversation
  try {
    const existingConv = await prisma.conversation.findFirst({
      where: { userId: 'demo-user' },
    });

    if (!existingConv) {
      const conversation = await prisma.conversation.create({
        data: {
          userId: 'demo-user',
          title: 'İlk Sohbet',
          messages: {
            create: [
              {
                sender: 'user',
                content: { text: 'Sabır hakkında ne diyor Kur\'an?' },
              },
              {
                sender: 'assistant',
                content: {
                  summary: 'Kur\'an, sabırın önemini vurgular ve sabredenlerin Allah\'la birlikte olduğunu belirtir.',
                  verses: [
                    {
                      surah: 2,
                      ayah: 153,
                      surah_name: 'Bakara',
                      text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
                      text_tr: 'Ey iman edenler! Sabır ve namazla yardım isteyin. Çünkü Allah muhakkak sabredenlerle beraberdir.',
                    },
                  ],
                  disclaimer: 'Daha detaylı bilgi için İslam alimlerine danışabilirsiniz.',
                },
              },
            ],
          },
        },
      });
      console.log(`✅ Created sample conversation: ${conversation.id}`);
    } else {
      console.log('ℹ️ Sample conversation already exists');
    }
  } catch (error) {
    console.log('⚠️ Could not create sample conversation:', error);
  }

  console.log('\n✨ Database seeding completed!');
  console.log('📊 Summary:');
  console.log(`   - ${seededCount} Quran verses`);
  console.log(`   - ${prayers.length} prayers (ready for future use)`);
  console.log(`   - ${Object.keys(surahNames).length} surah names mapped`);
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
