import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../widgets/step_progress_indicator.dart';

/// PIN Setup Screen (Story 2.1 - AC8)
/// Create 4-digit PIN for secure app access
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _pin = ['', '', '', ''];
  final List<String> _confirmPin = ['', '', '', ''];
  bool _isConfirming = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = false;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: StepProgressIndicator(
                currentStep: 4,
                totalSteps: 5,
                label: 'Secure Your Account',
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              _isConfirming ? 'Confirm Your PIN' : 'Create a 4-Digit PIN',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirming 
                  ? 'Re-enter your PIN to confirm'
                  : 'This PIN will be used for quick login',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // PIN Display
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => _buildPinDot(
                  _isConfirming ? _confirmPin[index] : _pin[index],
                  index,
                )),
              ),
            ),
            
            // Error Message
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Numeric Keypad
            if (_isLoading)
              const CircularProgressIndicator()
            else
              _buildNumericKeypad(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDot(String value, int index) {
    final isFilled = value.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 56,
      height: 64,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError 
              ? Colors.red 
              : (isFilled ? AppColors.primary : Colors.grey.shade300),
          width: 2,
        ),
      ),
      child: Center(
        child: isFilled
            ? const Text(
                '●',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map(_buildKeypadButton).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map(_buildKeypadButton).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map(_buildKeypadButton).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('', empty: true),
              _buildKeypadButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String value, {bool empty = false}) {
    if (empty) return const SizedBox(width: 72, height: 72);
    
    return GestureDetector(
      onTap: () => _onKeyTap(value),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _onKeyTap(String value) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    
    final currentPin = _isConfirming ? _confirmPin : _pin;
    
    // Find first empty slot
    for (int i = 0; i < 4; i++) {
      if (currentPin[i].isEmpty) {
        setState(() {
          currentPin[i] = value;
        });
        
        // Check if PIN is complete
        if (i == 3) {
          _onPinComplete();
        }
        break;
      }
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    
    final currentPin = _isConfirming ? _confirmPin : _pin;
    
    // Find last filled slot
    for (int i = 3; i >= 0; i--) {
      if (currentPin[i].isNotEmpty) {
        setState(() {
          currentPin[i] = '';
        });
        break;
      }
    }
  }

  void _onPinComplete() {
    if (!_isConfirming) {
      // Move to confirmation
      setState(() {
        _isConfirming = true;
      });
    } else {
      // Verify PINs match
      final pinStr = _pin.join();
      final confirmPinStr = _confirmPin.join();
      
      if (pinStr == confirmPinStr) {
        _savePin(pinStr);
      } else {
        _shakeController.forward(from: 0);
        setState(() {
          _hasError = true;
          _errorMessage = 'PINs don\'t match. Try again.';
          _confirmPin.fillRange(0, 4, '');
        });
      }
    }
  }

  Future<void> _savePin(String pin) async {
    setState(() => _isLoading = true);
    
    // TODO: Call API to save PIN
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.pushNamed(context, '/onboarding-complete');
    }
  }
}
