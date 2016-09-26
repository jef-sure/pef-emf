use ExtUtils::MakeMaker;
WriteMakefile(
	NAME             => "PEF::EMF",
	AUTHOR           => "Anton Petrusevich",
	VERSION          => "0.01",
	LICENSE          => "artistic_2",
	INSTALLDIRS      => 'site',
	MIN_PERL_VERSION => "5.014000",
	META_MERGE       => {
		"meta-spec" => {version => 2},
		resources   => {
			bugtracker => {web => 'https://github.com/jef-sure/pef-emf/issues'},
			repository => {
				type => 'git',
				url  => 'https://github.com/jef-sure/pef-emf.git',
				web  => 'https://github.com/jef-sure/pef-emf',
			},
		},
	},
	PREREQ_PM     => {},
	TEST_REQUIRES => {'Test::More' => 0},
	test          => {TESTS => "t/*.t"},
	dist          => {
		DIST_DEFAULT => 'all tardist',
		COMPRESS     => 'gzip -vf',
		SUFFIX       => '.gz',
	},
	clean     => {FILES => '*~',},
	realclean => {FILES => '*~',},
);
