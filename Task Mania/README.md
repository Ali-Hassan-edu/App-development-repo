# \# Task Manager App

# 

# A Flutter-based task management application with local notifications, repeating tasks, subtasks, dashboard analytics, and exporting options (CSV/PDF). The project uses Provider for state management and Sqflite for local storage.

# 

# \## 🚀 Features

# 

# \- Create, edit, delete tasks  

# \- Subtasks with progress tracking  

# \- Local notifications (scheduled reminders)  

# \- Repeating tasks (daily/weekly/manual)  

# \- Dashboard with task statistics  

# \- Light/Dark theme switching  

# \- Export tasks to PDF and CSV  

# \- Bottom navigation with multiple screens:

# &nbsp; - Dashboard

# &nbsp; - Today's Tasks

# &nbsp; - Completed Tasks

# &nbsp; - Repeating Tasks

# 

# ---

# 

# \## 📂 \*\*Project Structure\*\*

# 

# ```

# lib/

# │

# ├── core/

# │   └── theme/

# │       └── theme\_provider.dart

# │

# ├── data/

# │   ├── database/

# │   │   └── db\_helper.dart

# │   ├── models/

# │   │   ├── task\_model.dart

# │   │   └── subtask\_model.dart

# │   ├── repositories/

# │   │   └── task\_repository.dart

# │   └── services/

# │       ├── notification\_service.dart

# │       └── export\_service.dart

# │

# ├── features/

# │   ├── home/

# │   │   └── screens/

# │   │       └── main\_screen.dart

# │   │

# │   ├── dashboard/

# │   │   └── screens/

# │   │       └── dashboard\_screen.dart

# │   │

# │   ├── task\_management/

# │   │   ├── providers/

# │   │   │   └── task\_provider.dart

# │   │   └── screens/

# │   │       └── add\_edit\_task\_screen.dart

# │   │

# │   ├── today/

# │   │   └── screens/

# │   │       └── today\_task\_screen.dart

# │   │

# │   ├── completed/

# │   │   └── screens/

# │   │       └── completed\_task\_screen.dart

# │   │

# │   ├── repeated/

# │   │   └── screens/

# │   │       └── repeated\_task\_screen.dart

# │   │

# │   └── shared/

# │       └── widgets/

# │           └── task\_card.dart

# │

# ├── router/

# │   └── app\_router.dart

# │

# ├── main.dart

# │

# ```

# 

# ---

# 

# \## 🔔 \*\*Local Notifications\*\*

# 

# This project uses:

# 

# \- `flutter\_local\_notifications`

# \- `timezone`

# 

# Notifications are scheduled using:

# 

# ```dart

# NotificationService.instance.scheduleNotification(

# &nbsp; id,

# &nbsp; title,

# &nbsp; description,

# &nbsp; dueDate,

# );

# ```

# 

# ---

# 

# \## 🛠️ \*\*Tech Stack\*\*

# 

# | Feature | Package |

# |--------|---------|

# | State Management | Provider |

# | Local DB | Sqflite |

# | Notifications | flutter\_local\_notifications |

# | File Export | pdf, csv |

# | Date \& Formatting | intl |

# | File Paths | path\_provider |

# 

# 

# \## 📱 Android Setup Required

# 

# Make sure these permissions are added inside:

# 

# \### `AndroidManifest.xml`

# 

# ```xml

# <uses-permission android:name="android.permission.POST\_NOTIFICATIONS" />

# ```

# 

# ---

# 

# \## 🙌 Contribution

# 

# Pull requests are welcome!

# 

# ---

# 

# \## 📄 License

# 

# This project is licensed under your desired license (MIT recommended).



