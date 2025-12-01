import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting database seeding...');

  // Example seed data - In production, load from a complete Quran dataset
  const sampleVerses = [
    {
      surah: 1,
      ayah: 1,
      text_ar: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      text_tr: 'Rahman ve Rahim olan Allah\'ın adıyla',
    },
    {
      surah: 2,
      ayah: 153,
      text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      text_tr: 'Ey iman edenler! Sabır ve namazla Allah\'tan yardım isteyin. Şüphesiz Allah sabredenlerle beraberdir.',
    },
    {
      surah: 2,
      ayah: 286,
      text_ar: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      text_tr: 'Allah hiç kimseyi gücünün üstünde bir şeyle yükümlü tutmaz.',
    },
    {
      surah: 3,
      ayah: 159,
      text_ar: 'فَبِمَا رَحْمَةٍ مِّنَ اللَّهِ لِنتَ لَهُمْ',
      text_tr: 'Allah\'ın rahmeti sayesinde sen onlara yumuşak davrandın.',
    },
    {
      surah: 13,
      ayah: 28,
      text_ar: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      text_tr: 'İman edenler ve kalpleri Allah\'ı anmakla huzur bulanlar; haberiniz olsun ki kalpler ancak Allah\'ı anmakla huzur bulur.',
    },
    {
      surah: 29,
      ayah: 45,
      text_ar: 'إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ',
      text_tr: 'Şüphesiz namaz, insanı çirkin işlerden ve kötülükten alıkoyar.',
    },
    {
      surah: 94,
      ayah: 5,
      text_ar: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      text_tr: 'Çünkü her zorlukla beraber bir kolaylık vardır.',
    },
    {
      surah: 94,
      ayah: 6,
      text_ar: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      text_tr: 'Evet, her zorlukla beraber bir kolaylık vardır.',
    },
  ];

  // Seed Quran verses
  for (const verse of sampleVerses) {
    await prisma.quranVerse.upsert({
      where: {
        surah_ayah: {
          surah: verse.surah,
          ayah: verse.ayah,
        },
      },
      update: {},
      create: verse,
    });
  }

  console.log(`✅ Seeded ${sampleVerses.length} Quran verses`);

  // Create a sample conversation for testing
  const conversation = await prisma.conversation.create({
    data: {
      userId: 'demo-user',
      title: 'First Conversation',
      messages: {
        create: [
          {
            sender: 'user',
            content: {
              text: 'Sabır hakkında ne diyor Kuran?',
            },
          },
          {
            sender: 'assistant',
            content: {
              summary: 'Kuran, sabırın önemini vurgular ve sabredenlerin Allah\'la birlikte olduğunu belirtir.',
              verses: [
                {
                  surah: 2,
                  ayah: 153,
                  text_ar: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
                  text_tr: 'Ey iman edenler! Sabır ve namazla Allah\'tan yardım isteyin. Şüphesiz Allah sabredenlerle beraberdir.',
                },
              ],
              disclaimer: 'Bu yanıt Kuran ayetlerine dayanmaktadır. Daha detaylı bilgi için İslam alimlerine danışabilirsiniz.',
            },
          },
        ],
      },
    },
  });

  console.log(`✅ Created sample conversation with ID: ${conversation.id}`);
  console.log('✨ Database seeding completed!');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });


