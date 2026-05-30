// Popüler egzersiz hareketleri (300+ adet)
const List<String> popularExercises = [
  // Göğüs
  'Bench Press', 'Bench Press (Barbell)', 'Incline Bench Press', 'Incline Bench Press (Barbell)',
  'Decline Bench Press', 'Decline Bench Press (Barbell)', 'Dumbbell Bench Press', 'Dumbbell Press',
  'Incline Dumbbell Press', 'Decline Dumbbell Press', 'Dumbbell Flyes', 'Chest Fly (Dumbbell)',
  'Cable Fly (High to Low)', 'Cable Fly (Low to High)', 'Chest Press Machine', 'Pec Deck Machine',
  'Cable Crossovers', 'Push-up', 'Push-ups', 'Diamond Push-up', 'Diamond Push-ups',
  'Wide Grip Push-up', 'Incline Push-up', 'Incline Push-ups', 'Decline Push-up', 'Decline Push-ups',
  'Dips', 'Dips (Chest focus)', 'Chest Dips', 'Tricep Dips', 'Pec Flyes',
  'Landmine Press', 'Floor Press', 'Svend Press', 'Decline Cable Fly', 'Incline Cable Fly',
  'Floor Press (Dumbbell)', 'Board Press', 'Spoto Press', 'Guillotine Press',
  'Neutral Grip Bench Press', 'Spiderman Push-up', 'Hindu Push-up', 'Plyo Push-up',
  
  // Sırt
  'Deadlift', 'Deadlift (Conventional)', 'Romanian Deadlift', 'Stiff-Legged Deadlift', 'Stiff Leg Deadlift',
  'Sumo Deadlift', 'Rack Pull', 'Pendlay Row', 'Renegade Row', 'Hyperextension',
  'Pull-up', 'Pull-ups', 'Chin-up', 'Chin-ups', 'Lat Pulldown', 'Lat Pulldown (Wide Grip)',
  'Close Grip Lat Pulldown', 'Single Arm Lat Pulldown', 'Seated Cable Row', 'Bent Over Row',
  'Bent Over Barbell Row', 'One-Arm Dumbbell Row', 'One Arm Dumbbell Row', 'T-Bar Row',
  'Face Pull', 'Face Pulls', 'Face Pull (Cable)', 'Straight Arm Pulldown', 'Superman',
  'Inverted Row', 'Hammer Strength Row', 'Good Mornings', 'Cable Rows', 'Chest Supported Row',
  'Wide Grip Pull-ups', 'Close Grip Pull-ups', 'Meadows Row', 'Seal Row', 'Gorilla Row',
  'Kroc Row', 'Pull-over (Dumbbell)', 'Pull-over (Cable)', 'Dumbbell Pullover',
  'Snatch Grip Row', 'Weighted Pull-up', 'Towel Pull-up', 'L-Sit Pull-up',
  'Zercher Deadlift', 'Deficit Deadlift', 'Snatch Grip Deadlift', 'Paused Deadlift',
  'Trap Bar Deadlift', 'Low Cable Row (Single Arm)', 'High Cable Row (Single Arm)',
  
  // Omuz
  'Overhead Press', 'Military Press', 'Dumbbell Shoulder Press', 'Arnold Press',
  'Lateral Raise', 'Front Raise', 'Rear Delt Fly', 'Rear Delt Flyes', 'Upright Row',
  'Upright Rows', 'Machine Shoulder Press', 'Cable Lateral Raise', 'Cable Lateral Raises',
  'Pike Push-up', 'Handstand Push-up', 'Handstand Push-ups', 'Push Press', 'Bradford Press',
  'Smith Machine Press', 'Lu Raise', 'Reverse Pec Deck', 'Scaption', 'Kettlebell Press',
  'Pike Press', 'Clean and Press', 'Reverse Fly (Machine)', 'Reverse Fly (Dumbbell)',
  'Y-Raise', 'T-Raise', 'W-Raise', 'Cuban Press', 'Z-Press', 'Viking Press',
  'Klokov Press', 'Behind the Neck Press', 'Bus Driver',
  
  // Kollar
  'Barbell Curl', 'Dumbbell Bicep Curl', 'Dumbbell Curl', 'Hammer Curl', 'Preacher Curl',
  'Concentration Curl', 'Incline Dumbbell Curl', 'Cable Curl', '21s Curl', '21s',
  'Spider Curl', 'Z-Bar Curl', 'Drag Curl', 'Zottman Curl', 'Reverse Grip Barbell Curl',
  'Hammer Strength Bicep Curl', 'Cable Rope Hammer Curl', 'Cable Hammer Curl',
  'Triceps Pushdown', 'Tricep Pushdown', 'Skull Crusher', 'Skull Crushers',
  'Overhead Dumbbell Extension', 'Overhead Tricep Extension', 'Dips (Triceps focus)',
  'Close Grip Bench Press', 'Close-Grip Bench Press', 'Triceps Kickback', 'Tricep Kickbacks',
  'Bench Dips', 'Rope Pushdown', 'Tate Press', 'Single Arm Cable Extension', 'JM Press',
  'Wrist Curl', 'Reverse Wrist Curl', 'Plate Pinch', 'Finger Curls', 'Fat Gripz Curl',
  'Kelso Shrug', 'Hise Shrug', 'Single Arm Shrug', 'Behind the Back Shrug',
  'Shrugs', 'Barbell Shrugs', 'Dumbbell Shrugs',
  
  // Bacaklar
  'Squat', 'Back Squat', 'Front Squat', 'Bulgarian Split Squat', 'Lunges', 'Walking Lunges',
  'Reverse Lunges', 'Leg Press', 'Leg Extension', 'Leg Curl', 'Romanian Deadlift',
  'Stiff Leg Deadlift', 'Goblet Squat', 'Sumo Squat', 'Hack Squat', 'Hip Thrust',
  'Glute Bridge', 'Standing Calf Raise', 'Seated Calf Raise', 'Calf Raises',
  'Standing Calf Raises', 'Seated Calf Raises', 'Step-ups', 'Box Jump', 'Box Jumps',
  'Pistol Squat', 'Curtsy Lunge', 'Side Lunge', 'Donkey Kicks', 'Fire Hydrants',
  'Wall Sit', 'Adductor Machine', 'Abductor Machine', 'Kettlebell Swing',
  'Zercher Squat', 'Single Leg RDL', 'Leg Press Calf Raise', 'Single Leg Squat',
  'Jump Squats', 'Box Squat', 'Pause Squat', 'Jefferson Squat', 'Belt Squat',
  'Sissy Squat', 'Nordic Hamstring Curl', 'Glute Ham Raise', 'Single Leg Press',
  'Donkey Calf Raise', 'Tibialis Raise', 'Hack Squat (Barbell)', 'Landmine Squat',
  'Cossack Squat', 'Kang Squat', 'Pin Squat', 'Anderson Squat',
  
  // Karın/Core
  'Plank', 'Side Plank', 'Russian Twist', 'Russian Twists', 'Bicycle Crunch', 'Bicycle Crunches',
  'Leg Raises', 'Lying Leg Raise', 'Hanging Leg Raise', 'Hanging Leg Raises',
  'Flutter Kicks', 'Mountain Climber', 'Mountain Climbers', 'Burpees', 'Crunch', 'Crunches',
  'Sit-up', 'Sit-ups', 'Ab Wheel Rollout', 'Ab Wheel', 'Dead Bug', 'Bird Dog',
  'Superman', 'Cable Crunches', 'Reverse Crunch', 'Reverse Crunches', 'V-Ups',
  'Toe Touches', 'Heel Touches', 'Captain\'s Chair', 'Woodchopper', 'Woodchoppers',
  'Hollow Body Hold', 'Superman Hold', 'Pallof Press', 'Cable Woodchopper (High to Low)',
  'Cable Woodchopper (Low to High)', 'Hollow Rock', 'Leg Flutter', 'Knee to Elbow',
  'Cross Body Mountain Climbers', 'Oblique Crunch', 'Side Crunch', 'Weighted Crunch',
  'Cable Crunch', 'Dragon Flag', 'L-Sit', 'Scorpion Stretch',
  
  // Kardiyo
  'Treadmill Running', 'Elliptical', 'Stationary Bike', 'Rowing Machine',
  'Battle Ropes', 'Jump Rope', 'Sprint Intervals', 'Stair Climber',
  'Assault Bike', 'Rowing', 'Cycling', 'Shadow Boxing', 'Speed Skaters',
  
  // Fonksiyonel
  'Kettlebell Swing', 'Medicine Ball Slam', 'Farmer Walk', 'Farmer\'s Walk',
  'Sandbag Carry', 'Atlas Stone', 'Tire Flip', 'Sledgehammer', 'Turkish Get-up',
  'Clean and Press', 'Snatch', 'Thruster', 'Thrusters', 'Wall Ball',
  'Suitcase Carry', 'Overhead Carry', 'Zercher Carry', 'Waiter\'s Carry',
  'Sled Push', 'Sled Pull', 'Clean and Jerk', 'Power Clean',
  'Medicine Ball Toss', 'Chest Pass', 'Overhead Slam', 'Broad Jump',
  'Vertical Jump', 'Depth Jump', 'Single Leg Box Jump', 'Lateral Box Jump',
  'Tuck Jump', 'Star Jump', 'Split Squat Jump', 'Frog Jump',
  'Inchworm', 'Plank Jack', 'Commando Plank', 'Plank to Push-up',
  'Bear Crawl', 'Bear Crawl Shoulder Tap', 'Plank Shoulder Tap', 'Beast Hold',
  'Jumping Jacks', 'High Knees', 'Butt Kicks', 'Skaters',
  
  // Esneklik/Yoga
  'Cat-Cow Stretch', 'World\'s Greatest Stretch', 'Child\'s Pose', 'Cobra Stretch',
  'Downward Dog', 'Upward Dog', 'Pigeon Pose', 'Tree Pose', 'Warrior I',
  'Warrior II', 'Warrior III', 'Triangle Pose', 'Boat Pose', 'Bridge Pose',
  'Happy Baby Pose', 'Sit-throughs', 'Kick-throughs', 'Windmill',
  
  // Özel Hareketler
  'Muscle-up', 'Archer Push-up', 'Plyo Push-up', 'Dragon Flag', 'L-Sit',
  'Around the World (Dumbbell)', 'Halo (Kettlebell)', 'Single Leg Glute Bridge',
  'Frog Pump', 'Banded Clamshells', 'Monster Walk', 'Lateral Band Walk',
  'Landmine Row', 'Landmine Rotation', 'Muscle-up (Ring)', 'Ring Dips',
  'Ring Rows', 'Ring Push-up', 'Bulgarian Ring Dip'
];
