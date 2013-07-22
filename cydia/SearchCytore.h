#include "Cytore.hpp"

struct PackageValue : Cytore::Block {
	Cytore::Offset<PackageValue> next_;

	uint32_t index_ : 23;
	uint32_t subscribed_ : 1;
	uint32_t : 8;

	int32_t first_;
	int32_t last_;

	uint16_t vhash_;
	uint16_t nhash_;

	char version_[8];
	char name_[];
};

struct MetaValue : Cytore::Block {
	uint32_t active_;
	Cytore::Offset<PackageValue> packages_[1 << 16];
};
