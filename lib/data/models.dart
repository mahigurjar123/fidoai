import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// ─── Feature Model ─────────────────────────────────────────
class FeatureModel {
  final String tag;
  final IconData icon;
  final String title;
  final String shortDesc;
  final String longDesc;
  final List<String> bullets;
  final LinearGradient gradient;
  final Color color;

  const FeatureModel({
    required this.tag,
    required this.icon,
    required this.title,
    required this.shortDesc,
    required this.longDesc,
    required this.bullets,
    required this.gradient,
    required this.color,
  });
}

const features = <FeatureModel>[
  FeatureModel(
    tag: 'SMART CHAT',
    icon: Icons.chat_bubble_rounded,
    title: 'AI Chat System',
    shortDesc: 'GPT-4o powered conversations with 128K context memory.',
    longDesc:
        'Talk to Fido AI naturally. Ask questions, brainstorm ideas, write code, draft emails — all powered by GPT-4o with up to 128K context window for the longest conversations.',
    bullets: [
      'Multi-turn conversation memory',
      'Code syntax highlighting',
      'Voice input & TTS output',
      '40+ language support',
      'Markdown rendering',
    ],
    gradient: AppColors.purpleGrad,
    color: AppColors.purple,
  ),
  FeatureModel(
    tag: 'VISUAL STUDIO',
    icon: Icons.auto_awesome_rounded,
    title: 'AI Image Generator',
    shortDesc: 'Generate stunning images from simple text prompts.',
    longDesc:
        'Create photorealistic images, digital art, logos, and illustrations from text. Supports DALL·E 3, Stable Diffusion XL, and Midjourney-style aesthetics with HD output.',
    bullets: [
      'Text-to-image generation',
      'HD 1024×1024 output',
      'Batch generate 4 images',
      'Style transfer & variations',
      'Image editing & inpainting',
    ],
    gradient: AppColors.blueGrad,
    color: AppColors.blue,
  ),
  FeatureModel(
    tag: 'LIGHTNING FAST',
    icon: Icons.bolt_rounded,
    title: 'Real-Time Processing',
    shortDesc: 'Sub-100ms latency with global edge infrastructure.',
    longDesc:
        'Experience AI at the speed of thought. Our edge-optimized infrastructure delivers streaming responses in milliseconds, with 99.9% uptime and global CDN coverage.',
    bullets: [
      'Token-by-token streaming',
      '<100ms first response',
      '99.9% uptime SLA',
      'Global CDN network',
      'Auto-scaling infrastructure',
    ],
    gradient: AppColors.cyanGrad,
    color: AppColors.cyan,
  ),
  FeatureModel(
    tag: 'ENTERPRISE GRADE',
    icon: Icons.shield_rounded,
    title: 'Privacy & Security',
    shortDesc: 'AES-256 encryption with zero data retention.',
    longDesc:
        'Your data belongs to you. Fido AI uses military-grade encryption, zero data retention policies, and GDPR-compliant infrastructure. We never train on your data.',
    bullets: [
      'AES-256 encryption',
      'Zero data retention mode',
      'GDPR & CCPA compliant',
      '2FA authentication',
      'SOC 2 Type II certified',
    ],
    gradient: AppColors.pinkGrad,
    color: AppColors.pink,
  ),
];

// ─── Pricing Model ─────────────────────────────────────────
class PricingModel {
  final String name;
  final String monthlyPrice;
  final String yearlyPrice;
  final Color color;
  final LinearGradient gradient;
  final List<(bool, String)> features;
  final bool isPopular;
  final String cta;

  const PricingModel({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.color,
    required this.gradient,
    required this.features,
    this.isPopular = false,
    required this.cta,
  });
}

const pricingPlans = <PricingModel>[
  PricingModel(
    name: 'STARTER',
    monthlyPrice: 'FREE',
    yearlyPrice: 'FREE',
    color: Color(0xFF6A6AB8),
    gradient: LinearGradient(colors: [Color(0xFF6A6AB8), Color(0xFF4A4A88)]),
    cta: 'Start Free',
    features: [
      (true, '50 AI Chat messages / day'),
      (true, '10 Image generations / day'),
      (true, 'GPT-3.5 Turbo model'),
      (true, 'Basic chat history (7 days)'),
      (true, 'Standard response speed'),
      (false, 'GPT-4o access'),
      (false, 'Voice input & TTS'),
      (false, 'API access'),
    ],
  ),
  PricingModel(
    name: 'PRO',
    monthlyPrice: '\$19',
    yearlyPrice: '\$15',
    color: AppColors.purple,
    gradient: AppColors.purpleGrad,
    isPopular: true,
    cta: 'Get Pro Now',
    features: [
      (true, 'Unlimited AI Chat messages'),
      (true, '200 Image generations / day'),
      (true, 'GPT-4o (128K context)'),
      (true, '30-day chat history'),
      (true, 'Priority response speed'),
      (true, 'Voice input & TTS output'),
      (true, 'Image editing & inpainting'),
      (false, 'Dedicated API access'),
    ],
  ),
  PricingModel(
    name: 'ENTERPRISE',
    monthlyPrice: '\$99',
    yearlyPrice: '\$79',
    color: AppColors.blue,
    gradient: AppColors.blueGrad,
    cta: 'Contact Sales',
    features: [
      (true, 'Unlimited everything'),
      (true, 'Unlimited image generations'),
      (true, 'Dedicated GPU instances'),
      (true, 'GPT-4o + Custom fine-tuning'),
      (true, 'Unlimited history & exports'),
      (true, 'Full REST API (10K req/day)'),
      (true, 'Team collaboration (10 seats)'),
      (true, '24/7 Priority support'),
    ],
  ),
];

// ─── Testimonial Model ─────────────────────────────────────
class TestimonialModel {
  final String quote;
  final String name;
  final String role;
  final String initials;
  final Color color;

  const TestimonialModel({
    required this.quote,
    required this.name,
    required this.role,
    required this.initials,
    required this.color,
  });
}

const testimonials = <TestimonialModel>[
  TestimonialModel(
    quote:
        'Fido AI completely replaced 5 separate AI tools I was paying for. The image generator alone is worth 10x the price. Absolutely mind-blowing.',
    name: 'Arjun Sharma',
    role: 'Full-Stack Developer, Mumbai',
    initials: 'AS',
    color: AppColors.purple,
  ),
  TestimonialModel(
    quote:
        'The chat system understands context better than any AI I have used. I use it daily for writing, coding, and research. The UI is gorgeous too!',
    name: 'Priya Nair',
    role: 'Content Creator & YouTuber',
    initials: 'PN',
    color: AppColors.blue,
  ),
  TestimonialModel(
    quote:
        'We integrated Fido AI into our workflow and customer support response time dropped by 70%. The API is clean, fast, and well-documented.',
    name: 'Rahul Gupta',
    role: 'CTO, TechVentures India',
    initials: 'RG',
    color: AppColors.cyan,
  ),
  TestimonialModel(
    quote:
        'The 3D animations and premium design make this feel like a 500 dollar a month product. Getting it at 19 dollars feels like stealing. My team is obsessed.',
    name: 'Sofia Martinez',
    role: 'UX Designer, Barcelona',
    initials: 'SM',
    color: AppColors.pink,
  ),
];

// ─── FAQ Model ─────────────────────────────────────────────
class FAQModel {
  final String question;
  final String answer;
  const FAQModel({required this.question, required this.answer});
}

const faqs = <FAQModel>[
  FAQModel(
    question: 'Is Fido AI built with Flutter for web?',
    answer:
        'Yes! Fido AI is a Flutter Web application compiled to high-performance JavaScript/WASM. It delivers native-quality animations, 3D effects, and smooth 60fps interactions directly in the browser. Works on Chrome, Firefox, Safari, and Edge.',
  ),
  FAQModel(
    question: 'What AI models does Fido AI use?',
    answer:
        'Fido AI uses OpenAI GPT-4o for chat with a 128K context window, DALL-E 3 for premium image generation, and Stable Diffusion XL as an alternative engine. Pro and Enterprise users get priority access to all models.',
  ),
  FAQModel(
    question: 'Can I use Fido AI for commercial projects?',
    answer:
        'Absolutely. Pro and Enterprise plans include full commercial usage rights for all AI-generated content. All outputs are yours to use, sell, or distribute without attribution requirements.',
  ),
  FAQModel(
    question: 'Is there an API available?',
    answer:
        'Yes! Enterprise plan users get full REST API access with up to 10,000 requests per day. Our API follows OpenAI-compatible standards, so migration from existing integrations is seamless.',
  ),
  FAQModel(
    question: 'How is my data protected?',
    answer:
        'All data is encrypted with AES-256 in transit and at rest. We are GDPR and CCPA compliant. Free and Pro users can enable Zero Data Mode to prevent any storage of conversations. We are SOC 2 Type II certified.',
  ),
  FAQModel(
    question: 'What makes Fido AI different from ChatGPT?',
    answer:
        'Fido AI combines chat, image generation, voice input, real-time streaming, and team collaboration into one premium platform with enterprise-grade security — all at a fraction of the cost of running separate tools.',
  ),
];
