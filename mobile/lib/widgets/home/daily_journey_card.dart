import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../styles/styles.dart';
import '../../services/daily_content_service.dart';
import '../share_story_modal.dart';

/// Daily content manager - fetches from API with fallback to hardcoded data
class DailyContent {
  static final DailyContentService _service = DailyContentService();
  static DailyContentResponse? _cachedContent;
  static DateTime? _cacheDate;
  
  // Fallback verses (used when API is unavailable)
  static const List<Map<String, dynamic>> _fallbackVerses = [
    {
      'surah': 'Al-Baqarah',
      'surahTr': 'Bakara Suresi',
      'ayah': 286,
      'arabic': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      'meaning': 'Allah hiç kimseye gücünün üstünde bir yük yüklemez.',
      'tafsir': 'Bu ayet, Allah\'ın kullarına karşı merhametini ve adaletini gösterir.',
    },
    {
      'surah': 'Al-Inshirah',
      'surahTr': 'İnşirâh Suresi',
      'ayah': 5,
      'arabic': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'meaning': 'Demek ki, zorlukla beraber kolaylık vardır.',
      'tafsir': 'Her zorluktan sonra bir kolaylık gelir. Allah kullarını asla yalnız bırakmaz.',
    },
    {
      'surah': 'Ar-Rad',
      'surahTr': 'Ra\'d Suresi',
      'ayah': 28,
      'arabic': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'meaning': 'Biliniz ki, kalpler ancak Allah\'ı anmakla huzur bulur.',
      'tafsir': 'Kalplerin gerçek huzuru ancak Allah\'ı zikretmekle mümkündür.',
    },
  ];

  // Complete collection of Quranic duas (Rabbana & Rabbi prayers)
  static const List<Map<String, String>> _fallbackPrayers = [
    // Surah Al-Fatiha
    {
      'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      'meaning': 'Bizi doğru yola ilet.',
    },
    // Surah Al-Baqarah
    {
      'arabic': 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
      'meaning': 'Rabbimiz! Bizden kabul buyur. Şüphesiz sen işitensin, bilensin.',
    },
    {
      'arabic': 'رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِن ذُرِّيَّتِنَا أُمَّةً مُّسْلِمَةً لَّكَ',
      'meaning': 'Rabbimiz! Bizi sana teslim olanlardan kıl, soyumuzdan da sana teslim olan bir ümmet çıkar.',
    },
    {
      'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'meaning': 'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
    },
    {
      'arabic': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      'meaning': 'Rabbimiz! Üzerimize sabır yağdır, ayaklarımızı sabit kıl ve inkarcı topluluğa karşı bize yardım et.',
    },
    {
      'arabic': 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
      'meaning': 'Rabbimiz! Unutursak veya yanılırsak bizi sorumlu tutma.',
    },
    {
      'arabic': 'رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا',
      'meaning': 'Rabbimiz! Bizden öncekilere yüklediğin gibi bize ağır yük yükleme.',
    },
    {
      'arabic': 'رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا',
      'meaning': 'Rabbimiz! Gücümüzün yetmediğini bize yükleme. Bizi affet, bağışla ve bize merhamet et.',
    },
    // Surah Al-Imran
    {
      'arabic': 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
      'meaning': 'Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi eğriltme, bize katından rahmet ver.',
    },
    {
      'arabic': 'رَبَّنَا إِنَّكَ جَامِعُ النَّاسِ لِيَوْمٍ لَّا رَيْبَ فِيهِ إِنَّ اللَّهَ لَا يُخْلِفُ الْمِيعَادَ',
      'meaning': 'Rabbimiz! Sen insanları, geleceğinde şüphe olmayan bir günde toplayacaksın. Allah vaadinden dönmez.',
    },
    {
      'arabic': 'رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ',
      'meaning': 'Rabbimiz! Biz iman ettik, günahlarımızı bağışla ve bizi ateş azabından koru.',
    },
    {
      'arabic': 'رَبَّنَا آمَنَّا بِمَا أَنزَلْتَ وَاتَّبَعْنَا الرَّسُولَ فَاكْتُبْنَا مَعَ الشَّاهِدِينَ',
      'meaning': 'Rabbimiz! İndirdiğine iman ettik ve Peygambere uyduk. Bizi şahitlerle beraber yaz.',
    },
    {
      'arabic': 'رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      'meaning': 'Rabbimiz! Günahlarımızı ve işlerimizdeki taşkınlıklarımızı bağışla, ayaklarımızı sabit kıl.',
    },
    {
      'arabic': 'رَبَّنَا مَا خَلَقْتَ هَٰذَا بَاطِلًا سُبْحَانَكَ فَقِنَا عَذَابَ النَّارِ',
      'meaning': 'Rabbimiz! Bunları boşuna yaratmadın, seni tenzih ederiz. Bizi ateş azabından koru.',
    },
    {
      'arabic': 'رَبَّنَا إِنَّكَ مَن تُدْخِلِ النَّارَ فَقَدْ أَخْزَيْتَهُ',
      'meaning': 'Rabbimiz! Sen kimi ateşe sokarsan onu rezil etmişsindir.',
    },
    {
      'arabic': 'رَبَّنَا إِنَّنَا سَمِعْنَا مُنَادِيًا يُنَادِي لِلْإِيمَانِ أَنْ آمِنُوا بِرَبِّكُمْ فَآمَنَّا',
      'meaning': 'Rabbimiz! "Rabbinize iman edin" diye çağıran bir davetçi işittik ve iman ettik.',
    },
    {
      'arabic': 'رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ',
      'meaning': 'Rabbimiz! Günahlarımızı bağışla, kötülüklerimizi ört ve iyilerle beraber canımızı al.',
    },
    {
      'arabic': 'رَبَّنَا وَآتِنَا مَا وَعَدتَّنَا عَلَىٰ رُسُلِكَ وَلَا تُخْزِنَا يَوْمَ الْقِيَامَةِ',
      'meaning': 'Rabbimiz! Peygamberlerin aracılığıyla bize vaat ettiklerini ver, kıyamet günü bizi rezil etme.',
    },
    // Surah An-Nisa
    {
      'arabic': 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      'meaning': 'Rabbimiz! Kendimize zulmettik. Bizi bağışlamaz ve bize merhamet etmezsen hüsrana uğrayanlardan oluruz.',
    },
    // Surah Al-Maidah
    {
      'arabic': 'رَبَّنَا آمَنَّا فَاكْتُبْنَا مَعَ الشَّاهِدِينَ',
      'meaning': 'Rabbimiz! İman ettik, bizi şahitlerden yaz.',
    },
    // Surah Al-Araf
    {
      'arabic': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ',
      'meaning': 'Rabbimiz! Üzerimize sabır yağdır ve bizi Müslüman olarak öldür.',
    },
    // Surah Yunus
    {
      'arabic': 'رَبَّنَا لَا تَجْعَلْنَا فِتْنَةً لِّلْقَوْمِ الظَّالِمِينَ وَنَجِّنَا بِرَحْمَتِكَ مِنَ الْقَوْمِ الْكَافِرِينَ',
      'meaning': 'Rabbimiz! Bizi zalimler için fitne kılma ve rahmetinle bizi inkarcılardan kurtar.',
    },
    // Surah Hud
    {
      'arabic': 'رَبِّ إِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ',
      'meaning': 'Rabbim! Hakkında bilgim olmayan şeyi senden istemekten sana sığınırım.',
    },
    // Surah Yusuf
    {
      'arabic': 'رَبِّ قَدْ آتَيْتَنِي مِنَ الْمُلْكِ وَعَلَّمْتَنِي مِن تَأْوِيلِ الْأَحَادِيثِ',
      'meaning': 'Rabbim! Bana mülkten verdin ve rüyaların yorumunu öğrettin.',
    },
    {
      'arabic': 'فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ أَنتَ وَلِيِّي فِي الدُّنْيَا وَالْآخِرَةِ تَوَفَّنِي مُسْلِمًا وَأَلْحِقْنِي بِالصَّالِحِينَ',
      'meaning': 'Göklerin ve yerin yaratıcısı! Sen dünya ve ahirette benim velimsin. Canımı Müslüman olarak al ve beni salihler arasına kat.',
    },
    // Surah Ibrahim
    {
      'arabic': 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      'meaning': 'Rabbim! Beni ve neslimi namazı dosdoğru kılanlardan eyle. Rabbimiz, duamı kabul et.',
    },
    {
      'arabic': 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      'meaning': 'Rabbimiz! Hesap gününde beni, anne babamı ve müminleri bağışla.',
    },
    // Surah Al-Isra
    {
      'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      'meaning': 'Rabbim! Onlar beni küçükken nasıl yetiştirdilerse, sen de onlara öyle merhamet et.',
    },
    {
      'arabic': 'رَّبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل لِّي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا',
      'meaning': 'Rabbim! Beni doğruluk girişiyle girdir, doğruluk çıkışıyla çıkar ve katından yardımcı bir güç ver.',
    },
    // Surah Al-Kahf
    {
      'arabic': 'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
      'meaning': 'Rabbimiz! Bize katından rahmet ver ve işimizde bize doğruyu kolaylaştır.',
    },
    // Surah Maryam
    {
      'arabic': 'رَبِّ إِنِّي وَهَنَ الْعَظْمُ مِنِّي وَاشْتَعَلَ الرَّأْسُ شَيْبًا وَلَمْ أَكُن بِدُعَائِكَ رَبِّ شَقِيًّا',
      'meaning': 'Rabbim! Kemiklerim gevşedi, başım ağardı. Rabbim, sana dua etmekle hiç bedbaht olmadım.',
    },
    // Surah Taha
    {
      'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      'meaning': 'Rabbim! Göğsümü aç, işimi kolaylaştır.',
    },
    {
      'arabic': 'رَبِّ زِدْنِي عِلْمًا',
      'meaning': 'Rabbim! İlmimi artır.',
    },
    // Surah Al-Anbiya
    {
      'arabic': 'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      'meaning': 'Senden başka ilah yoktur, seni tenzih ederim. Ben gerçekten zalimlerden oldum.',
    },
    {
      'arabic': 'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ',
      'meaning': 'Rabbim! Beni yalnız bırakma, sen varislerin en hayırlısısın.',
    },
    // Surah Al-Muminun
    {
      'arabic': 'رَّبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ',
      'meaning': 'Rabbim! Bağışla ve merhamet et. Sen merhametlilerin en hayırlısısın.',
    },
    {
      'arabic': 'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَن يَحْضُرُونِ',
      'meaning': 'Rabbim! Şeytanların vesveselerinden sana sığınırım. Yanımda bulunmalarından da sana sığınırım.',
    },
    // Surah Al-Furqan
    {
      'arabic': 'رَبَّنَا اصْرِفْ عَنَّا عَذَابَ جَهَنَّمَ إِنَّ عَذَابَهَا كَانَ غَرَامًا',
      'meaning': 'Rabbimiz! Cehennem azabını bizden uzaklaştır, onun azabı sürekli bir helaktir.',
    },
    {
      'arabic': 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      'meaning': 'Rabbimiz! Eşlerimizi ve çocuklarımızı bize göz aydınlığı kıl ve bizi takva sahiplerine önder yap.',
    },
    // Surah Ash-Shu'ara
    {
      'arabic': 'رَبِّ هَبْ لِي حُكْمًا وَأَلْحِقْنِي بِالصَّالِحِينَ',
      'meaning': 'Rabbim! Bana hikmet ver ve beni salihler arasına kat.',
    },
    {
      'arabic': 'وَاجْعَل لِّي لِسَانَ صِدْقٍ فِي الْآخِرِينَ',
      'meaning': 'Sonrakiler arasında beni güzel bir dille anılanlardan kıl.',
    },
    {
      'arabic': 'وَاجْعَلْنِي مِن وَرَثَةِ جَنَّةِ النَّعِيمِ',
      'meaning': 'Beni nimet cennetinin varislerinden kıl.',
    },
    {
      'arabic': 'وَلَا تُخْزِنِي يَوْمَ يُبْعَثُونَ',
      'meaning': 'İnsanların diriltileceği gün beni rezil etme.',
    },
    // Surah An-Naml
    {
      'arabic': 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ',
      'meaning': 'Rabbim! Bana ve anne babama verdiğin nimetlere şükretmemi ilham et.',
    },
    // Surah Al-Qasas
    {
      'arabic': 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      'meaning': 'Rabbim! Bana indireceğin her hayra muhtacım.',
    },
    {
      'arabic': 'رَبِّ نَجِّنِي مِنَ الْقَوْمِ الظَّالِمِينَ',
      'meaning': 'Rabbim! Beni zalimler topluluğundan kurtar.',
    },
    // Surah Al-Ankabut
    {
      'arabic': 'رَبِّ انصُرْنِي عَلَى الْقَوْمِ الْمُفْسِدِينَ',
      'meaning': 'Rabbim! Bozguncu topluluğa karşı bana yardım et.',
    },
    // Surah Ghafir (Al-Mu'min)
    {
      'arabic': 'رَبَّنَا وَسِعْتَ كُلَّ شَيْءٍ رَّحْمَةً وَعِلْمًا فَاغْفِرْ لِلَّذِينَ تَابُوا وَاتَّبَعُوا سَبِيلَكَ',
      'meaning': 'Rabbimiz! Her şeyi rahmet ve ilimle kuşattın. Tövbe edip senin yoluna uyanları bağışla.',
    },
    {
      'arabic': 'رَبَّنَا وَأَدْخِلْهُمْ جَنَّاتِ عَدْنٍ الَّتِي وَعَدتَّهُمْ',
      'meaning': 'Rabbimiz! Onları vaat ettiğin Adn cennetlerine koy.',
    },
    // Surah Az-Zukhruf
    {
      'arabic': 'رَبِّ إِمَّا تُرِيَنِّي مَا يُوعَدُونَ رَبِّ فَلَا تَجْعَلْنِي فِي الْقَوْمِ الظَّالِمِينَ',
      'meaning': 'Rabbim! Eğer onlara vaat edileni bana göstereceksen, beni zalimler arasına katma.',
    },
    // Surah Al-Ahqaf
    {
      'arabic': 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ',
      'meaning': 'Rabbim! Bana ve anne babama verdiğin nimetlere şükretmemi ve razı olacağın salih amel işlememi ilham et.',
    },
    // Surah Al-Hashr
    {
      'arabic': 'رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ وَلَا تَجْعَلْ فِي قُلُوبِنَا غِلًّا لِّلَّذِينَ آمَنُوا',
      'meaning': 'Rabbimiz! Bizi ve bizden önce iman eden kardeşlerimizi bağışla, kalplerimizde müminlere karşı kin bırakma.',
    },
    // Surah Al-Mumtahanah
    {
      'arabic': 'رَبَّنَا عَلَيْكَ تَوَكَّلْنَا وَإِلَيْكَ أَنَبْنَا وَإِلَيْكَ الْمَصِيرُ',
      'meaning': 'Rabbimiz! Sana tevekkül ettik, sana yöneldik ve dönüş sanadır.',
    },
    {
      'arabic': 'رَبَّنَا لَا تَجْعَلْنَا فِتْنَةً لِّلَّذِينَ كَفَرُوا وَاغْفِرْ لَنَا رَبَّنَا إِنَّكَ أَنتَ الْعَزِيزُ الْحَكِيمُ',
      'meaning': 'Rabbimiz! Bizi inkarcılar için fitne kılma ve bizi bağışla. Sen Aziz ve Hakimsin.',
    },
    // Surah At-Tahrim
    {
      'arabic': 'رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      'meaning': 'Rabbimiz! Nurumuzu tamamla ve bizi bağışla. Şüphesiz sen her şeye kadirsin.',
    },
    // Surah Nuh
    {
      'arabic': 'رَّبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَن دَخَلَ بَيْتِيَ مُؤْمِنًا وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ',
      'meaning': 'Rabbim! Beni, anne babamı, evime mümin olarak gireni ve tüm mümin erkek ve kadınları bağışla.',
    },
    // Other essential duas
    {
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'meaning': 'Allah bize yeter. O ne güzel vekildir!',
    },
    {
      'arabic': 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      'meaning': 'Allah bana yeter. Ondan başka ilah yoktur. Ona tevekkül ettim. O büyük Arşın Rabbidir.',
    },
  ];

  /// Fetch daily content from API (with caching)
  static Future<void> fetchDailyContent() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Return cached content if it's from today
    if (_cachedContent != null && _cacheDate == todayDate) {
      return;
    }
    
    try {
      _cachedContent = await _service.getDailyContent();
      _cacheDate = todayDate;
    } catch (e) {
      debugPrint('Failed to fetch daily content: $e');
      // Will use fallback data
    }
  }

  /// Get verse of the day (from API or fallback)
  static Map<String, dynamic> get verseOfDay {
    if (_cachedContent != null) {
      final verse = _cachedContent!.verseOfDay;
      return {
        'surah': verse.surahName,
        'surahTr': '${verse.surahName} Suresi',
        'ayah': verse.ayah,
        'arabic': verse.arabic,
        'meaning': verse.turkish,
        'tafsir': _cachedContent!.tafsir?.commentary ?? 
                  'Bu ayet, Allah\'ın kullarına olan merhametini gösterir.',
      };
    }
    
    // Fallback: rotate based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _fallbackVerses[dayOfYear % _fallbackVerses.length];
  }
  
  /// Get tafsir data (from API or fallback)
  static Map<String, dynamic>? get tafsirOfDay {
    if (_cachedContent?.tafsir != null) {
      final tafsir = _cachedContent!.tafsir!;
      return {
        'surahTr': '${tafsir.surahName} Suresi',
        'arabic': tafsir.arabic,
        'meaning': tafsir.turkish,
        'tafsir': tafsir.commentary ?? 'Bu ayet üzerine tefekkür ediniz.',
      };
    }
    return verseOfDay; // Use verse of day as fallback
  }

  /// Get prayer of the day (from API or fallback)
  static Map<String, String> get prayerOfDay {
    if (_cachedContent != null) {
      final prayer = _cachedContent!.prayer;
      return {
        'arabic': prayer.arabic,
        'meaning': prayer.turkish,
        'source': prayer.source ?? '',
      };
    }
    
    // Fallback: rotate based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _fallbackPrayers[dayOfYear % _fallbackPrayers.length];
  }

  /// Get a random prayer (for variety)
  static Map<String, String> getRandomPrayer() {
    if (_cachedContent != null) {
      return prayerOfDay;
    }
    return _fallbackPrayers[Random().nextInt(_fallbackPrayers.length)];
  }
  
  /// Legacy getter for backward compatibility
  static List<Map<String, String>> get prayers => _fallbackPrayers;
}

/// Expandable card widget for daily journey activities
class ExpandableDailyJourneyCard extends StatefulWidget {
  final String title;
  final String duration;
  final IconData icon;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;
  final Color? accentColor;
  final Widget? expandedContent;
  final CardType cardType;
  final Function(bool)? onExpansionChanged;

  const ExpandableDailyJourneyCard({
    super.key,
    required this.title,
    required this.duration,
    required this.icon,
    this.isCompleted = false,
    this.isLocked = false,
    this.onTap,
    this.accentColor,
    this.expandedContent,
    this.cardType = CardType.generic,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableDailyJourneyCard> createState() => _ExpandableDailyJourneyCardState();
}

enum CardType { verse, tefsir, prayer, generic }

class _ExpandableDailyJourneyCardState extends State<ExpandableDailyJourneyCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _arrowAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  
  // Cached content to prevent rebuilding during animation
  Map<String, String>? _cachedPrayer;

  @override
  void initState() {
    super.initState();
    
    // Pre-cache the prayer on init
    if (widget.cardType == CardType.prayer) {
      _cachedPrayer = DailyContent.getRandomPrayer();
    }
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.isLocked) return;
    
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    
    widget.onExpansionChanged?.call(_isExpanded);
    widget.onTap?.call();
  }

  Widget _buildExpandedContent() {
    switch (widget.cardType) {
      case CardType.verse:
        return _buildVerseContent();
      case CardType.tefsir:
        return _buildTefsirContent();
      case CardType.prayer:
        return _buildPrayerContent();
      case CardType.generic:
        return widget.expandedContent ?? const SizedBox.shrink();
    }
  }

  Widget _buildVerseContent() {
    final verse = DailyContent.verseOfDay;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            // Surah badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GlobalAppStyle.accentColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '${verse['surahTr']} • Ayet ${verse['ayah']}',
                style: const TextStyle(
                  color: GlobalAppStyle.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Arabic text - Right aligned
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                verse['arabic'] as String,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 24,
                  height: 2.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 12,
                    ),
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Turkish meaning
            Text(
              verse['meaning'] as String,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 10,
                  ),
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Share button
            _buildShareButton(
              ShareContent(
                arabicText: verse['arabic'] as String,
                turkishText: verse['meaning'] as String,
                surahName: verse['surahTr'] as String,
                verseNumber: 'Ayet ${verse['ayah']}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTefsirContent() {
    final verse = DailyContent.verseOfDay;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            // Tefsir header badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GlobalAppStyle.accentColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    size: 12,
                    color: GlobalAppStyle.accentColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tefsir • ${verse['surahTr']}',
                    style: const TextStyle(
                      color: GlobalAppStyle.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tafsir text
            Text(
              verse['tafsir'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.95),
                height: 1.6,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 10,
                  ),
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Wisdom with light bulb
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 18,
                    color: Colors.amber.shade400,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Her zorlukla beraber bir kolaylık vardır.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.amber.shade200,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Share button
            _buildShareButton(
              ShareContent(
                arabicText: verse['arabic'] as String,
                turkishText: '${verse['tafsir']}\n\n"${verse['meaning']}"',
                surahName: 'Tefsir • ${verse['surahTr']}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerContent() {
    // Use cached prayer to prevent changes during animation
    final prayer = _cachedPrayer ?? DailyContent.getRandomPrayer();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            // Quran paper styled container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F0E3),
                    Color(0xFFF5ECD8),
                    Color(0xFFF2E8D0),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFFE57373), // Soft red for prayer
                    width: 4,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B7355).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 14,
                      color: Colors.red.withOpacity(0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prayer badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                size: 12,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Günün Duası',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Arabic prayer - Right aligned
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFFD4C4A8).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            prayer['arabic']!,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 22,
                              height: 2.0,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1408),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Turkish meaning
                        Text(
                          prayer['meaning']!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4A4035),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Share button for prayer
                        _buildShareButton(
                          ShareContent(
                            arabicText: prayer['arabic']!,
                            turkishText: prayer['meaning']!,
                            surahName: 'Günün Duası',
                          ),
                          isDarkTheme: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(ShareContent content, {bool isDarkTheme = false}) {
    return GestureDetector(
      onTap: () {
        ShareStoryModal.show(context, content);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkTheme 
              ? Colors.red.withOpacity(0.15) 
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkTheme 
                ? Colors.red.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.share_rounded,
              size: 16,
              color: isDarkTheme 
                  ? Colors.red.shade400
                  : Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Hikayende Paylaş',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkTheme 
                    ? Colors.red.shade700
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = widget.accentColor ?? GlobalAppStyle.accentColor;
    
    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // Base shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background image for verse card
                  if (widget.cardType == CardType.verse)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/daily_surah_bg_homepage.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Background image for tefsir card
                  if (widget.cardType == CardType.tefsir)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/daily_tefsir_bg_homepage.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Blur filter for cards without background images
                  if (widget.cardType != CardType.verse && widget.cardType != CardType.tefsir)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  // Main container
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (widget.cardType == CardType.verse || widget.cardType == CardType.tefsir)
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: widget.isCompleted 
                            ? effectiveAccentColor.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                      gradient: (widget.cardType != CardType.verse && widget.cardType != CardType.tefsir)
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0.06),
                                Colors.white.withOpacity(0.02),
                              ],
                              stops: const [0.0, 0.3, 1.0],
                            )
                          : null,
                    ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header (always visible)
                      SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Icon / Checkbox area
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: widget.isCompleted 
                                      ? effectiveAccentColor.withOpacity(0.2)
                                      : widget.isLocked 
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: widget.isCompleted || widget.isLocked
                                      ? null
                                      : Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                          width: 0.5,
                                        ),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.isCompleted 
                                        ? Icons.check_rounded 
                                        : widget.isLocked 
                                            ? Icons.lock_outline 
                                            : widget.icon,
                                    color: widget.isCompleted 
                                        ? effectiveAccentColor
                                        : Colors.white.withOpacity(widget.isLocked ? 0.5 : 0.85),
                                    size: 18,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 14),
                              
                              // Title and duration
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      widget.title.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: Colors.white.withOpacity(widget.isLocked ? 0.5 : 0.95),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.duration.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget.duration,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(widget.isLocked ? 0.4 : 0.7),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Trailing - completed label or arrow
                              if (widget.isCompleted)
                                Text(
                                  'TAMAMLANDI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: effectiveAccentColor,
                                  ),
                                )
                              else if (!widget.isLocked)
                                RotationTransition(
                                  turns: _arrowAnimation,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Expandable content
                      SizeTransition(
                        sizeFactor: _heightAnimation,
                        axisAlignment: -1,
                        child: _buildExpandedContent(),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A card widget for daily journey activities (Verse, Devotional, Prayer, Reward)
class DailyJourneyCard extends StatelessWidget {
  final String title;
  final String duration;
  final IconData icon;
  final bool isCompleted;
  final bool isLocked;
  final bool isExpandable;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  final Color? accentColor;

  const DailyJourneyCard({
    super.key,
    required this.title,
    required this.duration,
    required this.icon,
    this.isCompleted = false,
    this.isLocked = false,
    this.isExpandable = false,
    this.onTap,
    this.trailingWidget,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? GlobalAppStyle.accentColor;
    
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: isCompleted 
                      ? effectiveAccentColor.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Icon / Checkbox area
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? effectiveAccentColor.withOpacity(0.2)
                            : isLocked 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isCompleted || isLocked
                            ? null
                            : Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 0.5,
                              ),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted 
                              ? Icons.check_rounded 
                              : isLocked 
                                  ? Icons.lock_outline 
                                  : icon,
                          color: isCompleted 
                              ? effectiveAccentColor
                              : Colors.white.withOpacity(isLocked ? 0.5 : 0.85),
                          size: 18,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 14),
                    
                    // Title and duration
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.white.withOpacity(isLocked ? 0.5 : 0.95),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          if (duration.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Text(
                              duration,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(isLocked ? 0.4 : 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Trailing widget (DONE label or expand icon)
                    if (trailingWidget != null)
                      trailingWidget!
                    else if (isCompleted)
                      Text(
                        'TAMAMLANDI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: effectiveAccentColor,
                        ),
                      )
                    else if (isExpandable)
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 24,
                      )
                    else if (!isLocked)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A special reward card with decorative element
class DailyRewardCard extends StatelessWidget {
  final bool isLocked;
  final VoidCallback? onTap;

  const DailyRewardCard({
    super.key,
    this.isLocked = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: GlobalAppStyle.accentColor.withOpacity(0.15),
                border: Border.all(
                  color: GlobalAppStyle.accentColor.withOpacity(0.2),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GlobalAppStyle.accentColor.withOpacity(0.2),
                    GlobalAppStyle.accentColor.withOpacity(0.08),
                    GlobalAppStyle.accentColor.withOpacity(0.04),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative crescent moon
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: GlobalAppStyle.accentColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  
                  // Content - centered vertically
                  Positioned.fill(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Lock icon
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              isLocked ? Icons.lock_outline : Icons.card_giftcard,
                              color: Colors.white.withOpacity(isLocked ? 0.5 : 0.9),
                              size: 18,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 14),
                        
                        // Title
                        Text(
                            "GÜNÜN ÖDÜLÜ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white.withOpacity(isLocked ? 0.6 : 0.95),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
