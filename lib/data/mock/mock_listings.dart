import '../models/work_listing.dart';
import 'mock_categories.dart';

/// Demonstration work listings. Hirers and projects are fictional.
///
/// Dates are relative to [now] so the prototype always looks current.
List<WorkListing> buildMockListings(DateTime now) {
  DateTime daysFromNow(int d) => DateTime(now.year, now.month, now.day + d);
  DateTime ago({int hours = 0, int minutes = 0}) => now.subtract(Duration(hours: hours, minutes: minutes));

  return [
    WorkListing(
      id: 'w01',
      title: 'Need 3 masons for residential construction',
      category: MockCategories.mason,
      description:
          'Ground-floor brick and stone masonry for a new two-storey family house. '
          'Foundation and plinth are complete. Materials are on site and a '
          'helper team is already working. Lunch and tea provided.',
      district: 'Budgam',
      locality: 'Chadoora',
      workersNeeded: 3,
      compensationType: CompensationType.dailyWage,
      amount: 900,
      startDate: daysFromNow(1),
      durationLabel: 'About 3 weeks',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 2),
      skills: ['Brickwork', 'Stone masonry', 'Plastering'],
      experience: '3+ years on residential sites',
      hirer: const Hirer(
        name: 'Nowpora Builders',
        type: HirerType.contractor,
        memberSinceYear: 2025,
        postedCount: 14,
        isDemoVerified: true,
      ),
      interestedCount: 11,
      isUrgent: true,
    ),
    WorkListing(
      id: 'w02',
      title: 'Carpenter required for kitchen cabinets',
      category: MockCategories.carpenter,
      description:
          'Modular-style kitchen cabinets in plywood with laminate finish. Around '
          '12 running feet of base and wall units. Measurements and design '
          'reference available. Hardware will be supplied by the owner.',
      district: 'Srinagar',
      locality: 'Rawalpora',
      workersNeeded: 1,
      compensationType: CompensationType.fixedPrice,
      amount: 45000,
      startDate: daysFromNow(4),
      durationLabel: '10 to 12 days',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 5),
      skills: ['Cabinets', 'Laminate finishing', 'Measurements'],
      experience: 'Previous kitchen work preferred',
      hirer: const Hirer(
        name: 'Sameena K.',
        type: HirerType.homeowner,
        memberSinceYear: 2026,
        postedCount: 1,
      ),
      interestedCount: 6,
    ),
    WorkListing(
      id: 'w03',
      title: 'Electrician needed for house renovation',
      category: MockCategories.electrician,
      description:
          'Complete rewiring of an old three-bedroom house during renovation. '
          'Concealed conduit work, new distribution board and inverter '
          'connection. Wiring material will be purchased as per your list.',
      district: 'Anantnag',
      locality: 'Khanabal',
      workersNeeded: 2,
      compensationType: CompensationType.negotiable,
      startDate: daysFromNow(6),
      durationLabel: 'About 2 weeks',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 9),
      skills: ['House wiring', 'Panel boards', 'Inverter setup'],
      experience: '2+ years, own basic tools',
      hirer: const Hirer(
        name: 'Tariq M.',
        type: HirerType.homeowner,
        memberSinceYear: 2025,
        postedCount: 2,
        isDemoVerified: true,
      ),
      interestedCount: 4,
    ),
    WorkListing(
      id: 'w04',
      title: 'Eight construction helpers for a project',
      category: MockCategories.labourer,
      description:
          'Helpers needed for a commercial building project near the main road. '
          'Work includes material shifting, concrete mixing support and site '
          'cleaning. Daily payment at the end of each week.',
      district: 'Ganderbal',
      locality: 'Kangan Road',
      workersNeeded: 8,
      compensationType: CompensationType.dailyWage,
      amount: 600,
      startDate: daysFromNow(0),
      durationLabel: 'Around 1 month',
      durationBucket: DurationBucket.overMonth,
      postedAt: ago(minutes: 40),
      skills: ['Material handling', 'Concrete mixing'],
      experience: 'No experience required',
      hirer: const Hirer(
        name: 'Sindh Valley Infra',
        type: HirerType.business,
        memberSinceYear: 2024,
        postedCount: 22,
        isDemoVerified: true,
      ),
      interestedCount: 19,
      isUrgent: true,
    ),
    WorkListing(
      id: 'w05',
      title: 'Painter required for a two-storey house',
      category: MockCategories.painter,
      description:
          'Interior and exterior painting for a two-storey house, including '
          'putty on new walls and enamel on window grills. Paint will be '
          'supplied. Quote per job is welcome.',
      district: 'Baramulla',
      locality: 'Sopore',
      workersNeeded: 2,
      compensationType: CompensationType.quotation,
      startDate: daysFromNow(10),
      durationLabel: '2 to 3 weeks',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 20),
      skills: ['Interior painting', 'Exterior painting', 'Putty work'],
      experience: 'Show photos of past work if possible',
      hirer: const Hirer(name: 'Irfan W.', type: HirerType.homeowner, memberSinceYear: 2026, postedCount: 1),
      interestedCount: 3,
    ),
    WorkListing(
      id: 'w06',
      title: 'Plumber to fit two bathrooms and a geyser',
      category: MockCategories.plumber,
      description:
          'New bathroom fittings for two bathrooms including concealed '
          'pipework, sanitary installation and one 25-litre geyser. Tiles are '
          'already laid in one bathroom.',
      district: 'Srinagar',
      locality: 'Hyderpora',
      workersNeeded: 1,
      compensationType: CompensationType.fixedPrice,
      amount: 18000,
      startDate: daysFromNow(2),
      durationLabel: '5 days',
      durationBucket: DurationBucket.underWeek,
      postedAt: ago(hours: 3),
      skills: ['Bathroom fitting', 'Geyser installation', 'Pipe fitting'],
      experience: '3+ years',
      hirer: const Hirer(
        name: 'Aijaz R.',
        type: HirerType.homeowner,
        memberSinceYear: 2025,
        postedCount: 3,
        isDemoVerified: true,
      ),
      interestedCount: 7,
    ),
    WorkListing(
      id: 'w07',
      title: 'Khatamband ceiling for a living room',
      category: MockCategories.carpenter,
      description:
          'Traditional khatamband ceiling for a 16 by 14 feet living room. '
          'Looking for an experienced craftsperson who can suggest a '
          'pattern. Deodar or pine wood, to be discussed.',
      district: 'Pulwama',
      locality: 'Pampore',
      workersNeeded: 2,
      compensationType: CompensationType.negotiable,
      startDate: daysFromNow(14),
      durationLabel: '3 to 4 weeks',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 30),
      skills: ['Khatamband ceilings', 'Walnut wood', 'Finishing'],
      experience: '5+ years of traditional woodwork',
      hirer: const Hirer(name: 'Rehana B.', type: HirerType.homeowner, memberSinceYear: 2026, postedCount: 1),
      interestedCount: 5,
    ),
    WorkListing(
      id: 'w08',
      title: 'Subcontractor for boundary wall and gate',
      category: MockCategories.contractor,
      description:
          'Subcontract for a 180-feet boundary wall with RCC columns and a '
          'main gate frame. Team, scaffolding and supervision expected from '
          'the subcontractor. Materials supplied by the main contractor.',
      district: 'Jammu',
      locality: 'Gandhi Nagar',
      workersNeeded: 1,
      compensationType: CompensationType.quotation,
      startDate: daysFromNow(9),
      durationLabel: 'About 6 weeks',
      durationBucket: DurationBucket.overMonth,
      postedAt: ago(hours: 26),
      skills: ['Team management', 'RCC work', 'Estimation'],
      experience: 'Registered contractors with a team of 6+',
      hirer: const Hirer(
        name: 'Tawi Projects',
        type: HirerType.contractor,
        memberSinceYear: 2024,
        postedCount: 9,
        isDemoVerified: true,
      ),
      interestedCount: 2,
    ),
    WorkListing(
      id: 'w09',
      title: 'Electrician for shop lighting, one day',
      category: MockCategories.electrician,
      description:
          'Install 14 LED panel lights and two exhaust fans in a new shop. '
          'Points are already wired. Quick one-day job.',
      district: 'Srinagar',
      locality: 'Lal Chowk',
      workersNeeded: 1,
      compensationType: CompensationType.fixedPrice,
      amount: 2500,
      startDate: daysFromNow(1),
      durationLabel: '1 day',
      durationBucket: DurationBucket.oneDay,
      postedAt: ago(hours: 1),
      skills: ['Lighting', 'Fault finding'],
      experience: 'Any experience level',
      hirer: const Hirer(
        name: 'Downtown Traders',
        type: HirerType.business,
        memberSinceYear: 2025,
        postedCount: 4,
      ),
      interestedCount: 9,
    ),
    WorkListing(
      id: 'w10',
      title: 'Masons for retaining wall in hill area',
      category: MockCategories.mason,
      description:
          'Dry stone and cement retaining wall along a sloped plot. Around 60 '
          'feet long and 6 feet high. Stay arrangement possible for workers '
          'from outside the area.',
      district: 'Udhampur',
      locality: 'Chenani',
      workersNeeded: 4,
      compensationType: CompensationType.dailyWage,
      amount: 850,
      startDate: daysFromNow(5),
      durationLabel: 'About 2 weeks',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 46),
      skills: ['Stone masonry', 'RCC work'],
      experience: 'Hill-site experience preferred',
      hirer: const Hirer(name: 'Vikas S.', type: HirerType.homeowner, memberSinceYear: 2026, postedCount: 1),
      interestedCount: 4,
    ),
    WorkListing(
      id: 'w11',
      title: 'Labourers for snow-damage roof clearing',
      category: MockCategories.labourer,
      description:
          'Remove damaged tin sheets and debris from two houses after heavy '
          'snowfall. Safety gear provided. Two days of work.',
      district: 'Kupwara',
      locality: 'Handwara',
      workersNeeded: 5,
      compensationType: CompensationType.dailyWage,
      amount: 700,
      startDate: daysFromNow(3),
      durationLabel: '2 days',
      durationBucket: DurationBucket.underWeek,
      postedAt: ago(hours: 14),
      skills: ['Loading', 'Site cleaning'],
      experience: 'Comfortable working at height',
      hirer: const Hirer(
        name: 'Mushtaq L.',
        type: HirerType.homeowner,
        memberSinceYear: 2025,
        postedCount: 2,
      ),
      interestedCount: 8,
    ),
    WorkListing(
      id: 'w12',
      title: 'Wood polish for doors and windows',
      category: MockCategories.painter,
      description:
          'Polish and finish 9 doors and 14 windows in a newly built house. '
          'Melamine or PU finish, to be discussed after site visit.',
      district: 'Kathua',
      locality: 'Hiranagar',
      workersNeeded: 2,
      compensationType: CompensationType.negotiable,
      startDate: daysFromNow(12),
      durationLabel: '8 to 10 days',
      durationBucket: DurationBucket.fewWeeks,
      postedAt: ago(hours: 60),
      skills: ['Wood polish', 'Texture finish'],
      experience: '2+ years',
      hirer: const Hirer(name: 'Anita D.', type: HirerType.homeowner, memberSinceYear: 2026, postedCount: 1),
      interestedCount: 1,
    ),
  ];
}
