import SwiftUI

/// Coordinator for the 26-screen onboarding funnel.
///
/// Manages the `OnboardingViewModel` state machine and switches
/// between screens with horizontal slide transitions.
struct OnboardingFlowView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @AppStorage("numind.hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @StateObject private var viewModel: OnboardingViewModel

    init() {
        // Placeholder — actual initialization happens in .onAppear / body
        // via the environment object. We use a temporary store here.
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ))
    }

    var body: some View {
        ZStack {
            // Background (adapts to dark/light screens)
            (viewModel.isDarkScreen ? Theme.Colors.deepNavy : Theme.Colors.softBackground)
                .ignoresSafeArea()
                .animation(.easeOut(duration: 0.3), value: viewModel.isDarkScreen)

            VStack(spacing: 0) {
                // Top bar: progress + back button
                if viewModel.currentScreen != .welcome && viewModel.currentScreen != .welcomeConfirm {
                    topBar
                }

                // Screen content
                screenContent
                    .id(viewModel.currentScreen)
                    .transition(slideTransition)
            }
        }
        .animation(.easeInOut(duration: 0.32), value: viewModel.currentScreen)
        .onAppear {
            // Re-bind to the real progress store from environment
            viewModel.rebind(progressStore: progressStore, repository: LocalContentRepository())
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            if viewModel.showsBackButton {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(viewModel.isDarkScreen ? .white.opacity(0.7) : Theme.Colors.deepNavy)
                        .frame(width: 36, height: 36)
                }
            } else {
                Spacer().frame(width: 36)
            }

            if viewModel.showsProgressBar {
                OnboardingProgressBar(
                    value: viewModel.progressValue,
                    dark: viewModel.isDarkScreen
                )
            } else {
                Spacer()
            }

            Spacer().frame(width: 36)
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    // MARK: - Screen Router

    @ViewBuilder
    private var screenContent: some View {
        switch viewModel.currentScreen {
        case .welcome:
            WelcomeHookView(
                onGetStarted: { viewModel.advance() },
                onAlreadyHaveAccount: {
                    // TODO: Supabase auth flow
                    hasCompletedOnboarding = true
                }
            )

        case .socialProof:
            SocialProofView(onContinue: { viewModel.advance() })

        case .dailyMicro:
            DailyMicroView(onContinue: { viewModel.advance() })

        case .screenTime:
            ScreenTimeView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .confidence:
            ConfidenceRatingView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .motivation:
            MotivationPickerView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .aspiration:
            AspirationPickerView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .mirroring:
            MirroringView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .topicInterest:
            TopicInterestView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .timeCommitment:
            TimeCommitmentView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .kaizen:
            KaizenView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .adhd:
            ADHDScreenView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .nameInput:
            NameInputView(onContinue: { viewModel.advance() })

        case .ageRange:
            AgeRangeView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .diagnosticIntro:
            DiagnosticIntroView(onStart: { viewModel.startDiagnostic() })

        case .diagnosticQuiz:
            DiagnosticQuizView(viewModel: viewModel)

        case .preparingResults:
            PreparingResultsView(onFinish: { viewModel.finishPreparing() })

        case .diagnosticResults:
            DiagnosticResultsView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .personalizedPlan:
            PersonalizedPlanView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .notificationPermission:
            NotificationPermissionView(onContinue: { viewModel.advance() })

        case .paywallPriming:
            PaywallPrimingView(onContinue: { viewModel.advance() })

        case .streakGoal:
            StreakGoalView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .improvementProjection:
            ImprovementProjectionView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .trialReminder:
            TrialReminderView(viewModel: viewModel, onContinue: { viewModel.advance() })

        case .paywall:
            PaywallView(
                onSubscribe: {
                    // TODO: RevenueCat purchase flow
                    viewModel.advance()
                },
                onRestore: {
                    // TODO: RevenueCat restore purchases
                }
            )

        case .welcomeConfirm:
            WelcomeConfirmView(
                viewModel: viewModel,
                onStartFirstSession: {
                    viewModel.completeOnboarding()
                    hasCompletedOnboarding = true
                    // TODO: Launch first lesson directly
                },
                onExploreFirst: {
                    viewModel.completeOnboarding()
                    hasCompletedOnboarding = true
                }
            )
        }
    }

    // MARK: - Transition

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: viewModel.isForward ? .trailing : .leading),
            removal: .move(edge: viewModel.isForward ? .leading : .trailing)
        )
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(ProgressStore())
}
