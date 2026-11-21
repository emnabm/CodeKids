# CodeKids - Backend Web API

Backend API for **CodeKids**, an educational mobile game for children aged 10+ teaching programming fundamentals (Python). Built for integration with the Flutter mobile application.

---

## 🛠 Tech Stack

- **Framework**: .NET 8 Web API (Controllers)
- **Data Access**: Entity Framework Core 8 with SQLite (easily switched to SQL Server by modifying provider in `Program.cs`)
- **Security & Auth**: JWT Bearer tokens with HMAC-SHA256, BCrypt for password and PIN hashing
- **Documentation**: Swagger / OpenAPI with JWT Bearer authentication and XML comments
- **Testing**: xUnit with SQLite in-memory provider
- **Architecture**: Pragmatic 3-tier structure: `Controllers -> Services -> EF Core DbContext` (No MediatR, No Clean Architecture overhead)

---

## 🚀 Getting Started

### Prerequisites
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (v8.0.400+)

### Build & Run
1. Restore dependencies and build the solution:
   ```bash
   dotnet restore
   dotnet build
   ```
2. Apply EF Core migrations (the API also auto-migrates and seeds on startup):
   ```bash
   dotnet ef database update --project CodeKids.Api
   ```
3. Run the API:
   ```bash
   dotnet run --project CodeKids.Api
   ```
4. Access Swagger UI in your browser:
   ```
   https://localhost:7xxx/swagger
   http://localhost:5xxx/swagger
   ```

### Running Unit Tests
Execute the full test suite (32 tests covering unlock algorithms, idempotency, streak math, hint price escalation, and ownership checks):
```bash
dotnet test
```

---

## ⚙️ Configuration & Environment Variables

Settings are defined in [`appsettings.json`](file:///c:/Users/LENOVO/Desktop/codeKids/CodeKids.Api/appsettings.json) and can be overridden via environment variables:

| Setting Key | Description | Default / Example |
|-------------|-------------|-------------------|
| `ConnectionStrings:DefaultConnection` | Database connection string | `Data Source=codekids.db` |
| `Jwt:Key` | HMAC-SHA256 Secret Key (>= 256 bits) | Stored in config/env (never hardcoded) |
| `Jwt:Issuer` | JWT Issuer claim | `CodeKidsApi` |
| `Jwt:Audience` | JWT Audience claim | `CodeKidsApp` |
| `Jwt:ExpiryHours` | Regular parent/child session lifetime | `24` |
| `Jwt:ParentTokenExpiryMinutes` | PIN-verified parent-area session lifetime | `15` |

---

## 🔑 Demo Credentials & Pre-Seeded Content

The database automatically seeds idempotent initial data on startup:

### Demo Parent
- **Email**: `demo@codekids.com`
- **Password**: `Password123!`
- **PIN**: `1234`
- **Language**: `en`

### Demo Child
- **Name**: `Alex`
- **Age**: `10`
- **Avatar**: `avatar_robot_blue`
- **Flames**: `0` | **Streak**: `0`

### Seeded Level 1: "Instructions" (Python Basics)
Organized into 4 progressive stages:
1. **Stage 1 (Explanation)**: *"Welcome to Python"* (Reward: **10 flames**)
2. **Stage 2 (Quiz)**: *"First Commands Quiz"* (Reward: **25 flames**, 4 questions: MCQ, True/False, Order, FillBlank)
3. **Stage 3 (Quiz)**: *"Variables and Numbers"* (Reward: **25 flames**, 4 questions: MCQ, True/False, Order, FillBlank)
4. **Stage 4 (Final)**: *"Level 1 Final Test"* (Reward: **60 flames**, 4 comprehensive test questions)

### Seeded Badges
- `FIRST_STAGE`: "First Step" (awarded upon completing the first stage)
- `FIRST_QUIZ`: "Quiz Whiz" (awarded upon completing the first quiz stage)
- `LEVEL_1_COMPLETE`: "Level 1 Champion" (awarded upon completing all stages in Level 1)
- `STREAK_3`: "Flame Keeper" (awarded on a 3-day streak)
- `STREAK_7`: "Fire Master" (awarded on a 7-day streak)

---

## 📱 Flutter Client Contract: Question JSON Schemas

The client application validates answers locally for instant interactive feedback and question requeuing, while the server enforces all progression, flames, streak, and unlocking.

When calling `GET /stages/{id}?childId={childId}`, each question contains `options` and `answer` parsed as native JSON objects.

### 1. Multiple Choice (`Mcq`)
- **`options`**: Array of string choices.
- **`answer`**: Object with property `correct` containing the exact matching string.

```json
{
  "type": "Mcq",
  "text": "Which command displays words on the computer screen in Python?",
  "options": [
    "print()",
    "input()",
    "show()",
    "write()"
  ],
  "answer": {
    "correct": "print()"
  },
  "hintText": "Think of a printer putting words onto paper.",
  "explanationText": "In Python, print() sends output to the terminal or screen."
}
```

### 2. True / False (`TrueFalse`)
- **`options`**: Array `["True", "False"]`.
- **`answer`**: Object with property `correct` containing `"True"` or `"False"`.

```json
{
  "type": "TrueFalse",
  "text": "Python runs code from top to bottom, one instruction at a time.",
  "options": [
    "True",
    "False"
  ],
  "answer": {
    "correct": "True"
  },
  "hintText": "Imagine reading a comic book panel by panel from top to bottom.",
  "explanationText": "Programs execute sequentially line-by-line starting at the first line."
}
```

### 3. Order Instructions (`Order`)
- **`options`**: Array of steps (shuffled by the Flutter client when presented to the child).
- **`answer`**: Object with property `order` containing an array of strings in correct chronological execution order.

```json
{
  "type": "Order",
  "text": "Arrange these lines so the program greets the player, asks if ready, and finishes.",
  "options": [
    "print('Welcome, coder!')",
    "print('Are you ready?')",
    "print('Mission complete!')"
  ],
  "answer": {
    "order": [
      "print('Welcome, coder!')",
      "print('Are you ready?')",
      "print('Mission complete!')"
    ]
  },
  "hintText": "First say welcome, then ask the question, then say mission complete.",
  "explanationText": "Sequential order means the greeting must come before the ending."
}
```

### 4. Fill in the Blank (`FillBlank`)
- **`options`**: Array of available keyword chips (or empty array if keyboard input).
- **`answer`**: Object with property `correct` representing the missing token.

```json
{
  "type": "FillBlank",
  "text": "Complete the code to print hi: ____('Hi!')",
  "options": [
    "print",
    "show",
    "say",
    "echo"
  ],
  "answer": {
    "correct": "print"
  },
  "hintText": "The keyword is the standard 5-letter Python display function.",
  "explanationText": "We write print('Hi!') to call the print function."
}
```

---

## 🌐 API Endpoints Reference

| Method | Endpoint | Auth | Description | Status Codes |
|---|---|---|---|---|
| `POST` | `/auth/register` | None | Register parent account | `201`, `400`, `409` |
| `POST` | `/auth/login` | None | Login with parent email/password | `200`, `400`, `401` |
| `POST` | `/auth/verify-pin` | Bearer | Verify parent PIN -> 15-min parent-area token | `200`, `400`, `401` |
| `GET` | `/children` | Bearer | List children of authenticated parent | `200`, `401` |
| `POST` | `/children` | Bearer | Create a new child profile | `201`, `400`, `401` |
| `DELETE` | `/children/{id}` | Bearer | Delete a child profile (cascades child data) | `204`, `401`, `403`, `404` |
| `GET` | `/children/{id}/map` | Bearer | Levels, stages, unlock status, flames, streak | `200`, `401`, `403`, `404` |
| `GET` | `/stages/{id}?childId=` | Bearer | Stage questions & content (rejects locked) | `200`, `400`, `401`, `403`, `404` |
| `POST` | `/stages/{id}/hint` | Bearer | Purchase escalating hint (100, 150, 200...) | `200`, `400`, `401`, `403`, `409` |
| `POST` | `/stages/{id}/complete` | Bearer | Complete stage (idempotent, rewards, streak, badges) | `200`, `400`, `401`, `403`, `404` |
| `GET` | `/children/{id}/rewards` | Bearer | Flames, streak, 7-day activity, transactions, badges | `200`, `401`, `403`, `404` |
| `GET` | `/children/{id}/stats` | ParentArea | Parent PIN protected: stage completion, flames/day | `200`, `401`, `403`, `404` |

---

## 🛡️ Implementation of the Hard Rules

1. **Ownership**:
   - Every `/children/{id}/...` endpoint and `childId` payload verifies child ownership via `_childService.VerifyOwnershipAsync(parentId, childId)`.
   - Returns **403 Forbidden** if the child belongs to another parent, and **404 Not Found** if the child doesn't exist.
2. **Idempotent & Transactional Completion**:
   - `POST /stages/{id}/complete` rejects locked stages.
   - Calling `/complete` a second time never awards double flames or streak bonuses (`flamesEarned = 0, streakBonus = 0`).
   - Runs in a single DB transaction (`BeginTransactionAsync`): updates child flames, inserts `FlameTransaction` rows, sets `ChildStageProgress`, updates streak, and awards eligible badges atomically.
3. **Escalating Hint Price**:
   - Price calculated on the server from hints already used in the stage: `100 + (hintsAlreadyUsed * 50)`.
   - Checks balance and rejects with **409 Conflict** (`InsufficientFlamesException`) if flames are insufficient.
   - Debits balance and appends `FlameTransaction` inside a DB transaction.
4. **Streak Logic (Pure Method with UTC Dates)**:
   - Implemented in `StreakService.Calculate(currentStreak, lastActiveDateUtc, nowUtc)`.
   - Same day = no streak change, 0 bonus.
   - Next consecutive day = streak + 1, bonus = `min(streak * 5, 50)`.
   - Skipped day = streak resets to 1, bonus = 5.
5. **Secrets & Production Readiness**:
   - JWT secret key read from configuration / environment variables (`Jwt:Key`).
   - CORS policy `"AllowAll"` enabled for mobile app HTTP calls.
   - HTTPS redirection ready.
6. **ProblemDetails Error Handling**:
   - Global exception middleware transforms exceptions into standard RFC 7807 `application/problem+json` with proper HTTP codes (400, 401, 403, 404, 409).
7. **Language Fallback**:
   - Content fetched using parent's preference (`fr`, `ar`, `en`) with automatic fallback to `"en"`.
8. **Flames Balance Invariant**:
   - `Child.Flames` strictly matches the algebraic sum of all `FlameTransaction` rows for the child.
