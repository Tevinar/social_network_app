import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_app/features/auth/presentation/widgets/auth_field.dart';
import 'package:social_app/features/auth/presentation/widgets/auth_gradient_button.dart';

/// A sign in page widget.
class SignInPage extends StatefulWidget {
  /// Creates a [SignInPage].
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 30,
                ),
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailure) {
                      showSnackBar(context, state.message);
                    }
                  },
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sign In.',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AuthField(
                          hintText: 'Email',
                          controller: emailController,
                        ),
                        const SizedBox(height: 15),
                        AuthField(
                          hintText: 'Password',
                          controller: passwordController,
                          isObscureText: true,
                        ),
                        const SizedBox(height: 20),
                        AuthGradientButton(
                          buttonText: 'Sign In',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              BlocProvider.of<AuthBloc>(context).add(
                                AuthSignIn(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => const SignUpPageRoute().go(context),
                          child: RichText(
                            key: const Key('signup_text'),
                            text: TextSpan(
                              text: "Don't have an account ? ",
                              style: Theme.of(context).textTheme.titleMedium,
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppPallete.gradient2,
                                        fontWeight: FontWeight.bold,
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
            );
          },
        ),
      ),
    );
  }
}
