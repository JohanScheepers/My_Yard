// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider =
    StateProvider<int>((ref) => 0); // 0 for Home, 1 for Scan, 2 for Config
