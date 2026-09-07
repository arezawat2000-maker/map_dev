import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

/// A real programming snippet shown in the login typewriter.
class CodeSnippet {
  final String language;
  final String filename;
  final String code;

  const CodeSnippet({
    required this.language,
    required this.filename,
    required this.code,
  });
}

/// Curated authentic production-style snippets (short, readable).
const List<CodeSnippet> kLoginCodeSnippets = [
  CodeSnippet(
    language: 'Dart',
    filename: 'auth_gate.dart',
    code: '''@override
Widget build(BuildContext context) {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.hasData) return const HomePage();
      return const LoginScreen();
    },
  );
}''',
  ),
  CodeSnippet(
    language: 'TypeScript',
    filename: 'route.ts',
    code: '''export async function GET(req: Request) {
  const session = await auth();
  if (!session?.user) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const rows = await db.appRequest.findMany({
    where: { userId: session.user.id },
    orderBy: { createdAt: 'desc' },
  });
  return Response.json(rows);
}''',
  ),
  CodeSnippet(
    language: 'Swift',
    filename: 'RequestCard.swift',
    code: '''struct RequestCard: View {
  let title: String
  let status: RequestStatus

  var body: some View {
    HStack {
      Text(title).font(.headline)
      Spacer()
      StatusBadge(status: status)
    }
    .padding()
    .background(.ultraThinMaterial)
  }
}''',
  ),
  CodeSnippet(
    language: 'Kotlin',
    filename: 'RequestRepository.kt',
    code: '''suspend fun fetchRequests(uid: String): List<AppRequest> =
  firestore.collection("requests")
    .whereEqualTo("userId", uid)
    .orderBy("createdAt", Query.Direction.DESCENDING)
    .get()
    .await()
    .documents
    .mapNotNull { it.toObject() }''',
  ),
  CodeSnippet(
    language: 'Python',
    filename: 'requests.py',
    code: '''@router.post("/requests", response_model=AppRequest)
async def create_request(
    payload: CreateRequestDTO,
    user: User = Depends(get_current_user),
):
    doc = await db.requests.insert_one({
        **payload.model_dump(),
        "user_id": user.id,
        "status": "pending",
    })
    return await db.requests.find_one({"_id": doc.inserted_id})''',
  ),
  CodeSnippet(
    language: 'SQL',
    filename: 'analytics.sql',
    code: '''SELECT
  r.id,
  r.title,
  r.status,
  COUNT(m.id) AS message_count
FROM app_requests r
LEFT JOIN chat_messages m ON m.request_id = r.id
WHERE r.user_id = \$1
GROUP BY r.id
ORDER BY r.updated_at DESC;''',
  ),
  CodeSnippet(
    language: 'Firebase',
    filename: 'firestore.rules',
    code: '''match /users/{userId} {
  allow read: if request.auth != null
    && request.auth.uid == userId;
  allow write: if request.auth != null
    && request.auth.uid == userId
    && request.resource.data.email is string;
}''',
  ),
  CodeSnippet(
    language: 'Go',
    filename: 'handler.go',
    code: '''func (h *Handler) CreateRequest(w http.ResponseWriter, r *http.Request) {
  uid := middleware.UserID(r.Context())
  var body CreateRequestBody
  if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
    http.Error(w, err.Error(), http.StatusBadRequest)
    return
  }
  req, err := h.store.Insert(r.Context(), uid, body)
  writeJSON(w, req, err)
}''',
  ),
  CodeSnippet(
    language: 'Rust',
    filename: 'auth.rs',
    code: '''pub async fn verify_token(token: &str) -> Result<Claims, AuthError> {
  let data = decode::<Claims>(
    token,
    &DecodingKey::from_secret(SECRET.as_bytes()),
    &Validation::new(Algorithm::HS256),
  )?;
  Ok(data.claims)
}''',
  ),
  CodeSnippet(
    language: 'GraphQL',
    filename: 'schema.graphql',
    code: '''type AppRequest {
  id: ID!
  title: String!
  status: RequestStatus!
  messages: [ChatMessage!]!
}

type Mutation {
  createRequest(input: CreateRequestInput!): AppRequest!
}''',
  ),
];

/// Typewriter that cycles real code: type → pause → wipe → next.
class CodeTypingAnimation extends StatefulWidget {
  final List<CodeSnippet> snippets;
  final Duration charTypeDelay;
  final Duration charDeleteDelay;
  final Duration holdDelay;
  final Duration gapDelay;

  const CodeTypingAnimation({
    super.key,
    this.snippets = kLoginCodeSnippets,
    this.charTypeDelay = const Duration(milliseconds: 28),
    this.charDeleteDelay = const Duration(milliseconds: 14),
    this.holdDelay = const Duration(milliseconds: 1600),
    this.gapDelay = const Duration(milliseconds: 480),
  });

  @override
  State<CodeTypingAnimation> createState() => _CodeTypingAnimationState();
}

class _CodeTypingAnimationState extends State<CodeTypingAnimation>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late List<CodeSnippet> _deck;
  int _deckIndex = 0;

  CodeSnippet? _current;
  String _visible = '';
  bool _cursorOn = true;
  bool _running = true;

  late final AnimationController _cursorBlink;
  Timer? _loopKick;

  @override
  void initState() {
    super.initState();
    _deck = List<CodeSnippet>.from(widget.snippets)..shuffle(_rng);
    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..addStatusListener((status) {
        if (!mounted) return;
        if (status == AnimationStatus.completed) {
          setState(() => _cursorOn = false);
          _cursorBlink.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() => _cursorOn = true);
          _cursorBlink.forward();
        }
      });
    _cursorBlink.forward();
    _loopKick = Timer(const Duration(milliseconds: 320), _runLoop);
  }

  @override
  void dispose() {
    _running = false;
    _loopKick?.cancel();
    _cursorBlink.dispose();
    super.dispose();
  }

  CodeSnippet _nextSnippet() {
    if (_deckIndex >= _deck.length) {
      _deck.shuffle(_rng);
      _deckIndex = 0;
    }
    return _deck[_deckIndex++];
  }

  Future<void> _runLoop() async {
    while (_running && mounted) {
      final snippet = _nextSnippet();
      if (!mounted) return;
      setState(() {
        _current = snippet;
        _visible = '';
      });

      final code = snippet.code;
      for (var i = 1; i <= code.length; i++) {
        if (!_running || !mounted) return;
        setState(() => _visible = code.substring(0, i));
        final ch = code[i - 1];
        final delay = ch == '\n'
            ? widget.charTypeDelay * 2
            : (ch == ' ' ? widget.charTypeDelay * 0.55 : widget.charTypeDelay);
        await Future<void>.delayed(delay);
      }

      if (!_running || !mounted) return;
      await Future<void>.delayed(widget.holdDelay);

      for (var i = code.length - 1; i >= 0; i--) {
        if (!_running || !mounted) return;
        setState(() => _visible = code.substring(0, i));
        await Future<void>.delayed(widget.charDeleteDelay);
      }

      if (!_running || !mounted) return;
      await Future<void>.delayed(widget.gapDelay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _current?.language ?? 'Code';
    final file = _current?.filename ?? 'snippet';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MapDevTheme.cyan.withValues(alpha: 0.10),
            blurRadius: 36,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(24),
        opacity: 0.10,
        blur: 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TerminalChrome(language: lang, filename: file),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.black.withValues(alpha: 0.10),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  physics: const BouncingScrollPhysics(),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        ..._highlight(_visible),
                        TextSpan(
                          text: _cursorOn ? '▋' : ' ',
                          style: TextStyle(
                            color: MapDevTheme.cyan.withValues(alpha: 0.9),
                            fontFamily: 'Menlo',
                            fontFamilyFallback: const [
                              'Courier',
                              'monospace',
                            ],
                            fontSize: 12.5,
                            height: 1.55,
                            shadows: [
                              Shadow(
                                color: MapDevTheme.cyan.withValues(alpha: 0.55),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminalChrome extends StatelessWidget {
  final String language;
  final String filename;

  const _TerminalChrome({
    required this.language,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Row(
        children: [
          _Dot(color: const Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          _Dot(color: const Color(0xFFFFBD2E)),
          const SizedBox(width: 6),
          _Dot(color: const Color(0xFF28C840)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              filename,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                fontFamily: 'Menlo',
                fontFamilyFallback: const ['Courier', 'monospace'],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: MapDevTheme.cyan.withValues(alpha: 0.14),
              border: Border.all(
                color: MapDevTheme.cyan.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              language,
              style: TextStyle(
                color: MapDevTheme.cyan.withValues(alpha: 0.95),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

// ── Lightweight multi-language syntax tint ──────────────────────────

const _kBaseStyle = TextStyle(
  color: Color(0xFFC9D1D9),
  fontFamily: 'Menlo',
  fontFamilyFallback: ['Courier', 'monospace'],
  fontSize: 12.5,
  height: 1.55,
  letterSpacing: 0.15,
);

const _kKeywordStyle = TextStyle(
  color: Color(0xFFFF7B72),
  fontFamily: 'Menlo',
  fontFamilyFallback: ['Courier', 'monospace'],
  fontSize: 12.5,
  height: 1.55,
  letterSpacing: 0.15,
  fontWeight: FontWeight.w600,
);

const _kStringStyle = TextStyle(
  color: Color(0xFFA5D6FF),
  fontFamily: 'Menlo',
  fontFamilyFallback: ['Courier', 'monospace'],
  fontSize: 12.5,
  height: 1.55,
  letterSpacing: 0.15,
);

const _kCommentStyle = TextStyle(
  color: Color(0xFF8B949E),
  fontFamily: 'Menlo',
  fontFamilyFallback: ['Courier', 'monospace'],
  fontSize: 12.5,
  height: 1.55,
  letterSpacing: 0.15,
  fontStyle: FontStyle.italic,
);

const _kNumberStyle = TextStyle(
  color: Color(0xFF79C0FF),
  fontFamily: 'Menlo',
  fontFamilyFallback: ['Courier', 'monospace'],
  fontSize: 12.5,
  height: 1.55,
  letterSpacing: 0.15,
);

const _kTypeStyle = TextStyle(
  color: Color(0xFF7EE787),
  fontFamily: 'Menlo',
  fontFamilyFallback: ['Courier', 'monospace'],
  fontSize: 12.5,
  height: 1.55,
  letterSpacing: 0.15,
);

final _keywordRe = RegExp(
  r'\b(abstract|allow|async|await|break|case|catch|class|const|continue|'
  r'default|defer|do|else|enum|export|extends|false|final|fn|for|from|'
  r'func|function|get|if|impl|import|in|interface|is|let|match|mut|null|'
  r'override|package|private|pub|public|return|self|some|static|struct|'
  r'super|suspend|switch|this|throw|true|try|type|typedef|var|void|when|'
  r'where|while|with|yield|SELECT|FROM|WHERE|LEFT|JOIN|ON|GROUP|BY|'
  r'ORDER|AS|COUNT|DESC|ASC|AND|OR|NULL|INSERT|INTO|VALUES|UPDATE|'
  r'DELETE|CREATE|TABLE|INDEX|match|allow|read|write|if|request|auth|'
  r'uid|resource|data|Depends|Widget|View|HStack|Spacer|Text|Query|'
  r'Response|json|http|Error|Ok|Result|decode|Validation|Algorithm)\b',
);

final _typeHintRe = RegExp(
  r'\b([A-Z][A-Za-z0-9_]*|List|Map|String|Int|Bool|Boolean|User|'
  r'Request|Claims|AuthError|AppRequest|CreateRequestDTO|RequestStatus|'
  r'ChatMessage|CreateRequestInput|CreateRequestBody|Handler|'
  r'DecodingKey|StreamBuilder|HomePage|LoginScreen|StatusBadge)\b',
);

final _numberRe = RegExp(r'\b\d+\b');
final _stringRe = RegExp(r'''('(?:\\'|[^'])*'|"(?:\\"|[^"])*")''');
final _lineCommentRe = RegExp(r'(//|#).*$', multiLine: true);

List<TextSpan> _highlight(String source) {
  if (source.isEmpty) return const [];

  final spans = <TextSpan>[];
  var i = 0;

  while (i < source.length) {
    // Line comment
    final comment = _lineCommentRe.matchAsPrefix(source, i);
    if (comment != null &&
        (source.startsWith('//', i) || source.startsWith('#', i))) {
      spans.add(TextSpan(text: comment.group(0), style: _kCommentStyle));
      i = comment.end;
      continue;
    }

    // String
    final str = _stringRe.matchAsPrefix(source, i);
    if (str != null) {
      spans.add(TextSpan(text: str.group(0), style: _kStringStyle));
      i = str.end;
      continue;
    }

    // Keyword
    final kw = _keywordRe.matchAsPrefix(source, i);
    if (kw != null) {
      spans.add(TextSpan(text: kw.group(0), style: _kKeywordStyle));
      i = kw.end;
      continue;
    }

    // Type-ish identifier
    final ty = _typeHintRe.matchAsPrefix(source, i);
    if (ty != null) {
      spans.add(TextSpan(text: ty.group(0), style: _kTypeStyle));
      i = ty.end;
      continue;
    }

    // Number
    final num = _numberRe.matchAsPrefix(source, i);
    if (num != null) {
      spans.add(TextSpan(text: num.group(0), style: _kNumberStyle));
      i = num.end;
      continue;
    }

    // Plain run until next interesting char
    final next = _nextSpecial(source, i + 1);
    spans.add(TextSpan(text: source.substring(i, next), style: _kBaseStyle));
    i = next;
  }

  return spans;
}

int _nextSpecial(String source, int from) {
  for (var j = from; j < source.length; j++) {
    final c = source[j];
    if (c == '"' ||
        c == "'" ||
        c == '/' ||
        c == '#' ||
        _isIdentStart(c) ||
        _isDigit(c)) {
      return j;
    }
  }
  return source.length;
}

bool _isIdentStart(String c) {
  final code = c.codeUnitAt(0);
  return (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      code == 95;
}

bool _isDigit(String c) {
  final code = c.codeUnitAt(0);
  return code >= 48 && code <= 57;
}
