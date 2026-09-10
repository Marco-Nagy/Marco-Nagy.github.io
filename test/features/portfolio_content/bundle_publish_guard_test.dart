import 'package:flutter_test/flutter_test.dart';
import 'package:marco_portfolio/core/common/data_result.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/image_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/repositories/portfolio_repo.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/use_cases/bundle_use_case.dart';

import 'sample_bundle.dart';

/// `BundleUseCase.publish()` is the one call in this codebase that can put an
/// oversized or half-authored bundle in front of Firestore, so its guard is
/// worth its own test independent of the widget that calls it. Both refusals
/// have to fire *before* `PortfolioRepo.publish()` is ever called — this is
/// checked directly via [_FakeRepo.publishCalls], not just by asserting the
/// returned message, because a guard that fails open (still calling publish
/// after logging a warning) is a worse bug than one that never fires at all.
void main() {
  test('publishes a normal bundle and returns the repo result', () async {
    final repo = _FakeRepo(sampleBundle());
    final useCase = BundleUseCase(repo);

    final result = await useCase.publish();

    expect(result, isA<Success<PortfolioBundle>>());
    expect(repo.publishCalls, 1);
  });

  test('refuses an oversized bundle without calling publish', () async {
    // Padding one field past the budget is cheaper and clearer than building
    // a bundle that is realistically that large.
    final oversized = sampleBundle().copyWith(
      siteContent: sampleSiteContent().copyWith(
        summaryEn: 'x' * (1024 * 1024),
      ),
    );
    final repo = _FakeRepo(oversized);
    final useCase = BundleUseCase(repo);

    final result = await useCase.publish();

    expect(result, isA<Fail<PortfolioBundle>>());
    expect(
      (result as Fail<PortfolioBundle>).message,
      contains('Too large'),
    );
    expect(repo.publishCalls, 0);
  });

  test('refuses a bundle with an embedded image without calling publish', () async {
    final withEmbedded = sampleBundle().copyWith(
      siteContent: sampleSiteContent().copyWith(
        profileImage: ImageRef.embedded('base64stuff=='),
      ),
    );
    final repo = _FakeRepo(withEmbedded);
    final useCase = BundleUseCase(repo);

    final result = await useCase.publish();

    expect(result, isA<Fail<PortfolioBundle>>());
    expect(
      (result as Fail<PortfolioBundle>).message,
      contains('embedded'),
    );
    expect(repo.publishCalls, 0);
  });

  test('a failed read is reported without attempting to publish', () async {
    final repo = _FakeRepo(sampleBundle())..failRead = true;
    final useCase = BundleUseCase(repo);

    final result = await useCase.publish();

    expect(result, isA<Fail<PortfolioBundle>>());
    expect(repo.publishCalls, 0);
  });
}

/// Implements [PortfolioRepo] via `noSuchMethod` rather than every method:
/// `BundleUseCase` only ever calls [readBundle] and [publish], and a call to
/// anything else here is a sign the use case grew a dependency this test does
/// not know about, so it fails loudly instead of silently returning null.
class _FakeRepo implements PortfolioRepo {
  _FakeRepo(this._bundle);

  final PortfolioBundle _bundle;
  bool failRead = false;
  int publishCalls = 0;

  @override
  Future<DataResult<PortfolioBundle>> readBundle() async {
    if (failRead) return const Fail<PortfolioBundle>('Could not read');
    return Success<PortfolioBundle>(_bundle);
  }

  @override
  Future<DataResult<PortfolioBundle>> publish() async {
    publishCalls++;
    return Success<PortfolioBundle>(
      _bundle.copyWith(contentVersion: _bundle.contentVersion + 1),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Unexpected call: ${invocation.memberName}');
}
