import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';

/// Comprehensive English to Punjabi (Gurmukhi) Transliteration Utility
class PunjabiTransliteration {
  static final Map<String, String> commonWords = {
    'singh': 'ਸਿੰਘ',
    'kaur': 'ਕੌਰ',
    'kumar': 'ਕੁਮਾਰ',
    'kumari': 'ਕੁਮਾਰੀ',
    'sharma': 'ਸ਼ਰਮਾ',
    'verma': 'ਵਰਮਾ',
    'gupta': 'ਗੁਪਤਾ',
    'devi': 'ਦੇਵੀ',
    'ram': 'ਰਾਮ',
    'lal': 'ਲਾਲ',
    'preet': 'ਪ੍ਰੀਤ',
    'deep': 'ਦੀਪ',
    'inder': 'ਇੰਦਰ',
    'jeet': 'ਜੀਤ',
    'jit': 'ਜੀਤ',
    'winder': 'ਵਿੰਦਰ',
    'pal': 'ਪਾਲ',
    'veer': 'ਵੀਰ',
    'vir': 'ਵੀਰ',
    'jot': 'ਜੋਤ',
    'meet': 'ਮੀਤ',
    'mohan': 'ਮੋਹਨ',
    'sohan': 'ਸੋਹਨ',
    'rohan': 'ਰੋਹਨ',
    'sonu': 'ਸੋਨੂ',
    'monu': 'ਮੋਨੂ',
    'raj': 'ਰਾਜ',
    'raja': 'ਰਾਜਾ',
    'rani': 'ਰਾਣੀ',
    'pooja': 'ਪੂਜਾ',
    'priya': 'ਪ੍ਰਿਆ',
    'neha': 'ਨੇਹਾ',
    'simran': 'ਸਿਮਰਨ',
    'kirandeep': 'ਕਿਰਨਦੀਪ',
    'kiran': 'ਕਿਰਨ',
    'aman': 'ਅਮਨ',
    'raman': 'ਰਮਨ',
    'kamal': 'ਕਮਲ',
    'karan': 'ਕਰਨ',
    'harpreet': 'ਹਰਪ੍ਰੀਤ',
    'gurpreet': 'ਗੁਰਪ੍ਰੀਤ',
    'jaspreet': 'ਜਸਪ੍ਰੀਤ',
    'manpreet': 'ਮਨਪ੍ਰੀਤ',
    'navpreet': 'ਨਵਪ੍ਰੀਤ',
    'amandeep': 'ਅਮਨਦੀਪ',
    'sandeep': 'ਸੰਦੀਪ',
    'kuldeep': 'ਕੁਲਦੀਪ',
    'mandeep': 'ਮਨਦੀਪ',
    'hardeep': 'ਹਰਦੀਪ',
    'jagdeep': 'ਜਗਦੀਪ',
    'gurdeep': 'ਗੁਰਦੀਪ',
    'rajwinder': 'ਰਾਜਵਿੰਦਰ',
    'jaswinder': 'ਜਸਵਿੰਦਰ',
    'kulwinder': 'ਕੁਲਵਿੰਦਰ',
    'balwinder': 'ਬਲਵਿੰਦਰ',
    'harwinder': 'ਹਰਵਿੰਦਰ',
    'gurwinder': 'ਗੁਰਵਿੰਦਰ',
    'sukhwinder': 'ਸੁਖਵਿੰਦਰ',
    'paramjit': 'ਪਰਮਜੀਤ',
    'surjit': 'ਸੁਰਜੀਤ',
    'harjit': 'ਹਰਜੀਤ',
    'gurjit': 'ਗੁਰਜੀਤ',
    'kuljit': 'ਕੁਲਜੀਤ',
    'inderjit': 'ਇੰਦਰਜੀਤ',
    'baljit': 'ਬਲਜੀਤ',
    'manjit': 'ਮਨਜੀਤ',
    'sarabjit': 'ਸਰਬਜੀਤ',
    'davinder': 'ਦਵਿੰਦਰ',
    'ravinder': 'ਰਵਿੰਦਰ',
    'satnam': 'ਸਤਨਾਮ',
    'jaspal': 'ਜਸਪਾਲ',
    'harpal': 'ਹਰਪਾਲ',
    'ramesh': 'ਰਮੇਸ਼',
    'suresh': 'ਸੁਰੇਸ਼',
    'naresh': 'ਨਰੇਸ਼',
    'rajesh': 'ਰਾਜੇਸ਼',
    'mukesh': 'ਮੁਕੇਸ਼',
    'anil': 'ਅਨਿਲ',
    'sunil': 'ਸੁਨੀਲ',
    'deepak': 'ਦੀਪਕ',
    'vikas': 'ਵਿਕਾਸ',
    'vishal': 'ਵਿਸ਼ਾਲ',
    'sunita': 'ਸੁਨੀਤਾ',
    'anita': 'ਅਨੀਤਾ',
    'rekha': 'ਰੇਖਾ',
    'geeta': 'ਗੀਤਾ',
    'seema': 'ਸੀਮਾ',
    'reena': 'ਰੀਨਾ',
    'meena': 'ਮੀਨਾ',
    'mona': 'ਮੋਨਾ',
    'sonia': 'ਸੋਨੀਆ',
    'manoj': 'ਮਨੋਜ',
    'pankaj': 'ਪੰਕਜ',
    'sanjay': 'ਸੰਜੇ',
    'vijay': 'ਵਿਜੇ',
    'ajay': 'ਅਜੇ',
    'ashok': 'ਅਸ਼ੋਕ',
    'vinod': 'ਵਿਨੋਦ',
    'pramod': 'ਪ੍ਰਮੋਦ',
    'rohit': 'ਰੋਹਿਤ',
    'mohit': 'ਮੋਹਿਤ',
    'rahul': 'ਰਾਹੁਲ',
    'amit': 'ਅਮਿਤ',
    'sumit': 'ਸੁਮਿਤ',
    'dharam': 'ਧਰਮ',
    'dharm': 'ਧਰਮ',
    'kavita': 'ਕਵਿਤਾ',
    'radha': 'ਰਾਧਾ',
    'krishna': 'ਕ੍ਰਿਸ਼ਨਾ',
    'govind': 'ਗੋਵਿੰਦ',
    'anand': 'ਆਨੰਦ',
    'bhupinder': 'ਭੁਪਿੰਦਰ',
    'rupinder': 'ਰੁਪਿੰਦਰ',
    'jasbir': 'ਜਸਬੀਰ',
    'satbir': 'ਸਤਬੀਰ',
    'balbir': 'ਬਲਬੀਰ',
    'sukhbir': 'ਸੁਖਬੀਰ',
    'inderbir': 'ਇੰਦਰਬੀਰ',
  };

  static String transliterate(String text) {
    if (text.trim().isEmpty) return text;

    final words = text.split(' ');
    final List<String> resultWords = [];

    for (var word in words) {
      if (word.isEmpty) {
        resultWords.add('');
        continue;
      }

      final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (cleanWord.isEmpty) {
        resultWords.add(word);
        continue;
      }

      final lower = cleanWord.toLowerCase();
      if (commonWords.containsKey(lower)) {
        resultWords.add(commonWords[lower]!);
        continue;
      }

      resultWords.add(_transliterateWord(lower));
    }

    return resultWords.join(' ');
  }

  static String _transliterateWord(String input) {
    final Map<String, String> multiChars = {
      'sh': 'ਸ਼',
      'kh': 'ਖ',
      'gh': 'ਘ',
      'ch': 'ਚ',
      'chh': 'ਛ',
      'jh': 'ਝ',
      'th': 'ਥ',
      'dh': 'ਧ',
      'bh': 'ਭ',
      'ph': 'ਫ',
      'rh': 'ੜ',
      'aa': 'ਆ',
      'ee': 'ਈ',
      'oo': 'ਊ',
      'ai': 'ਐ',
      'au': 'ਔ',
    };

    final Map<String, String> multiMatras = {
      'aa': 'ਾ',
      'ee': 'ੀ',
      'oo': 'ੂ',
      'ai': 'ੈ',
      'au': 'ੌ',
    };

    final Map<String, String> singleConsonants = {
      'k': 'ਕ',
      'g': 'ਗ',
      'c': 'ਕ',
      'j': 'ਜ',
      't': 'ਤ',
      'd': 'ਦ',
      'n': 'ਨ',
      'p': 'ਪ',
      'f': 'ਫ਼',
      'b': 'ਬ',
      'm': 'ਮ',
      'y': 'ਯ',
      'r': 'ਰ',
      'l': 'ਲ',
      'v': 'ਵ',
      'w': 'ਵ',
      's': 'ਸ',
      'h': 'ਹ',
      'z': 'ਜ਼',
      'q': 'ਕ',
      'x': 'ਕਸ',
    };

    final Map<String, String> singleInitialVowels = {
      'a': 'ਅ',
      'i': 'ਇ',
      'u': 'ਉ',
      'e': 'ਏ',
      'o': 'ਓ',
    };

    final Map<String, String> singleMatras = {
      'a': 'ਾ',
      'i': 'ਿ',
      'u': 'ੁ',
      'e': 'ੇ',
      'o': 'ੋ',
    };

    StringBuffer sb = StringBuffer();
    int i = 0;
    bool prevWasConsonant = false;

    while (i < input.length) {
      if (i + 3 <= input.length) {
        String tri = input.substring(i, i + 3);
        if (multiChars.containsKey(tri)) {
          sb.write(multiChars[tri]);
          prevWasConsonant = true;
          i += 3;
          continue;
        }
      }

      if (i + 2 <= input.length) {
        String bi = input.substring(i, i + 2);
        if (multiMatras.containsKey(bi)) {
          if (prevWasConsonant) {
            sb.write(multiMatras[bi]);
          } else {
            sb.write(multiChars[bi]);
          }
          prevWasConsonant = false;
          i += 2;
          continue;
        } else if (multiChars.containsKey(bi)) {
          sb.write(multiChars[bi]);
          prevWasConsonant = true;
          i += 2;
          continue;
        }
      }

      String ch = input[i];
      if (singleConsonants.containsKey(ch)) {
        sb.write(singleConsonants[ch]);
        prevWasConsonant = true;
        i++;
      } else if (singleMatras.containsKey(ch)) {
        if (prevWasConsonant) {
          if (ch == 'a' && i == input.length - 1) {
            sb.write('ਾ');
          } else if (ch == 'a') {
            // Inherent vowel in Gurmukhi consonants
          } else {
            sb.write(singleMatras[ch]);
          }
        } else {
          sb.write(singleInitialVowels[ch] ?? ch);
        }
        prevWasConsonant = false;
        i++;
      } else {
        sb.write(ch);
        prevWasConsonant = false;
        i++;
      }
    }

    return sb.toString();
  }
}

/// Custom Bottom Sheet with Punjabi (Gurmukhi) Virtual Keyboard
class PunjabiKeyboardBottomSheet extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String? englishSourceText;
  final int maxLength;
  final VoidCallback? onDone;

  const PunjabiKeyboardBottomSheet({
    super.key,
    required this.controller,
    required this.title,
    this.englishSourceText,
    this.maxLength = 200,
    this.onDone,
  });

  @override
  State<PunjabiKeyboardBottomSheet> createState() => _PunjabiKeyboardBottomSheetState();
}

class _PunjabiKeyboardBottomSheetState extends State<PunjabiKeyboardBottomSheet> {
  late TextEditingController _editingController;
  int _activeTabIndex = 0; // 0: Consonants (ਵਿਅੰਜਨ), 1: Matras & Vowels (ਮਾਤਰਾਵਾਂ), 2: Numbers & Symbols (ਅੰਕ)

  // Punjabi Gurmukhi Letters
  final List<String> _consonants = [
    'ੳ', 'ਅ', 'ੲ', 'ਸ', 'ਹ',
    'ਕ', 'ਖ', 'ਗ', 'ਘ', 'ਙ',
    'ਚ', 'ਛ', 'ਜ', 'ਝ', 'ਞ',
    'ਟ', 'ਠ', 'ਡ', 'ਢ', 'ਣ',
    'ਤ', 'ਥ', 'ਦ', 'ਧ', 'ਨ',
    'ਪ', 'ਫ', 'ਬ', 'ਭ', 'ਮ',
    'ਯ', 'ਰ', 'ਲ', 'ਵ', 'ੜ',
    'ਸ਼', 'ਖ਼', 'ਗ਼', 'ਜ਼', 'ਫ਼', 'ਲ਼',
  ];

  final List<String> _matrasAndVowels = [
    'ਾ', 'ਿ', 'ੀ', 'ੁ', 'ੂ', 'ੇ', 'ੈ', 'ੋ', 'ੌ',
    'ੰ', 'ੱ', '਼', '੍', 'ੴ',
    'ਆ', 'ਇ', 'ਈ', 'ਉ', 'ਊ', 'ਏ', 'ਐ', 'ਓ', 'ਔ',
  ];

  final List<String> _numbersAndSymbols = [
    '੦', '੧', '੨', '੩', '੪', '੫', '੬', '੭', '੮', '੯',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '।', ',', '.', '-', '(', ')',
  ];

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.controller.text);
    _editingController.selection = TextSelection.fromPosition(
      TextPosition(offset: _editingController.text.length),
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    HapticFeedback.lightImpact();
    final currentText = _editingController.text;
    final selection = _editingController.selection;
    
    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = currentText.length;
      end = currentText.length;
    }

    final newText = currentText.replaceRange(start, end, text);
    if (newText.length > widget.maxLength) {
      HapticFeedback.mediumImpact();
      Get.snackbar(
        "Limit Reached",
        "${widget.title}: Maximum ${widget.maxLength} characters allowed",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final newSelectionIndex = start + text.length;

    _editingController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
    widget.controller.text = newText;
  }

  void _backspace() {
    HapticFeedback.lightImpact();
    final currentText = _editingController.text;
    final selection = _editingController.selection;

    if (currentText.isEmpty) return;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = currentText.length;
      end = currentText.length;
    }

    if (start == end) {
      if (start > 0) {
        // Handle grapheme clusters (Punjabi characters with matras)
        final characters = currentText.characters.toList();
        if (characters.isNotEmpty) {
          // Find which grapheme corresponds to cursor position
          int runningLength = 0;
          int charIndexToRemove = -1;
          for (int i = 0; i < characters.length; i++) {
            runningLength += characters[i].length;
            if (runningLength >= start) {
              charIndexToRemove = i;
              break;
            }
          }
          if (charIndexToRemove >= 0) {
            final removedLength = characters[charIndexToRemove].length;
            characters.removeAt(charIndexToRemove);
            final newText = characters.join();
            final newOffset = (start - removedLength).clamp(0, newText.length);
            _editingController.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: newOffset),
            );
            widget.controller.text = newText;
            return;
          }
        }
        final newText = currentText.substring(0, start - 1) + currentText.substring(end);
        _editingController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start - 1),
        );
        widget.controller.text = newText;
      }
    } else {
      final newText = currentText.replaceRange(start, end, '');
      _editingController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
      widget.controller.text = newText;
    }
  }

  void _convertFromEnglish() {
    if (widget.englishSourceText != null && widget.englishSourceText!.trim().isNotEmpty) {
      String punjabi = PunjabiTransliteration.transliterate(widget.englishSourceText!);
      if (punjabi.length > widget.maxLength) {
        punjabi = punjabi.substring(0, widget.maxLength);
        Get.snackbar(
          "Limit Reached",
          "${widget.title}: Maximum ${widget.maxLength} characters allowed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 10,
          duration: const Duration(seconds: 2),
        );
      }
      _editingController.text = punjabi;
      _editingController.selection = TextSelection.collapsed(offset: punjabi.length);
      widget.controller.text = punjabi;
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Title & Actions Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.keyboard_alt_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _editingController.clear();
                    widget.controller.clear();
                  },
                  icon: const Icon(Icons.clear_all, size: 20, color: Colors.redAccent),
                  label: const Text("ਸਾਫ਼ ਕਰੋ", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onDone?.call();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("ਹੋ ਗਿਆ (Done)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),

          // Live Text Field inside sheet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _editingController,
              readOnly: true,
              showCursor: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਨਾਮ ਦਿਖਾਈ ਦੇਵੇਗਾ...",
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                ),
              ),
            ),
          ),

          // Quick Action Bar: "Translate from English" if English text is available
          if (widget.englishSourceText != null && widget.englishSourceText!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: InkWell(
                onTap: _convertFromEnglish,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_fix_high, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "ਅੰਗਰੇਜ਼ੀ ਤੋਂ ਬਦਲੋ: \"${widget.englishSourceText!}\" ➔ \"${PunjabiTransliteration.transliterate(widget.englishSourceText!)}\"",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 6),

          // Category Selector (Tabs)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton("ਵਿਅੰਜਨ (Letters)", 0),
                const SizedBox(width: 8),
                _buildTabButton("ਮਾਤਰਾਵਾਂ (Matras)", 1),
                const SizedBox(width: 8),
                _buildTabButton("ਅੰਕ (Numbers)", 2),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Keyboard Keys Grid
          Container(
            height: 195,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildKeyboardGrid(),
          ),

          // Bottom Action Row: Space, Backspace, Done
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Row(
              children: [
                // Spacebar
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _insertText(' '),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.space_bar, size: 22, color: Colors.black54),
                          SizedBox(width: 6),
                          Text("Space / ਖਾਲੀ ਥਾਂ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Backspace
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _backspace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E8F0),
                        foregroundColor: Colors.black87,
                        elevation: 1,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Icon(Icons.backspace_outlined, size: 24, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardGrid() {
    List<String> currentKeys;
    int crossAxisCount;

    if (_activeTabIndex == 0) {
      currentKeys = _consonants;
      crossAxisCount = 6;
    } else if (_activeTabIndex == 1) {
      currentKeys = _matrasAndVowels;
      crossAxisCount = 6;
    } else {
      currentKeys = _numbersAndSymbols;
      crossAxisCount = 6;
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.25,
      ),
      itemCount: currentKeys.length,
      itemBuilder: (context, index) {
        final key = currentKeys[index];
        return InkWell(
          onTap: () => _insertText(key),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper method to open Punjabi Keyboard Bottom Sheet
void showPunjabiKeyboard({
  required BuildContext context,
  required TextEditingController controller,
  required String title,
  String? englishSourceText,
  int maxLength = 200,
  VoidCallback? onDone,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PunjabiKeyboardBottomSheet(
      controller: controller,
      title: title,
      englishSourceText: englishSourceText,
      maxLength: maxLength,
      onDone: onDone,
    ),
  );
}
