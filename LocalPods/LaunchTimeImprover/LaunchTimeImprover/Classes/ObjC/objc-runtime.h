//
//  objc-runtime.h
//  LaunchTimeImprover
//
//  Created by 0xxxD on 2023/4/18.
//

#ifndef objc_runtime_h
#define objc_runtime_h

#include <list>


#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segmentType;
typedef struct section_64 sectionType;
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segmentType;
typedef struct section sectionType;

#endif

typedef uintptr_t protocol_ref_t;  // protocol_t *, but unremapped
typedef struct classref * classref_t;


static inline void* memdup(const void *mem, size_t len)
{
    void *dup = malloc(len);
    memcpy(dup, mem, len);
    return dup;
}

struct PointerModifierNop {
    template <typename ListType, typename T>
    static T *modify(__unused const ListType &list, T *ptr) { return ptr; }
};

template <typename Element, typename List, uint32_t FlagMask>
struct entsize_list_tt {
    uint32_t entsizeAndFlags;
    uint32_t count;
    Element first;

    uint32_t entsize() const {
        return entsizeAndFlags & ~FlagMask;
    }
    uint32_t flags() const {
        return entsizeAndFlags & FlagMask;
    }

    Element& getOrEnd(uint32_t i) const {
        assert(i <= count);
        return *(Element *)((uint8_t *)&first + i*entsize());
    }
    Element& get(uint32_t i) const {
        assert(i < count);
        return getOrEnd(i);
    }

    size_t byteSize() const {
        return sizeof(*this) + (count-1)*entsize();
    }

    List *duplicate() const {
        return (List *)memdup(this, this->byteSize());
    }

    struct iterator;
    const iterator begin() const {
        return iterator(*static_cast<const List*>(this), 0);
    }
    iterator begin() {
        return iterator(*static_cast<const List*>(this), 0);
    }
    const iterator end() const {
        return iterator(*static_cast<const List*>(this), count);
    }
    iterator end() {
        return iterator(*static_cast<const List*>(this), count);
    }

    struct iterator {
        uint32_t entsize;
        uint32_t index;  // keeping track of this saves a divide in operator-
        Element* element;

        typedef std::random_access_iterator_tag iterator_category;
        typedef Element value_type;
        typedef ptrdiff_t difference_type;
        typedef Element* pointer;
        typedef Element& reference;

        iterator() { }

        iterator(const List& list, uint32_t start = 0)
            : entsize(list.entsize())
            , index(start)
            , element(&list.getOrEnd(start))
        { }

        const iterator& operator += (ptrdiff_t delta) {
            element = (Element*)((uint8_t *)element + delta*entsize);
            index += (int32_t)delta;
            return *this;
        }
        const iterator& operator -= (ptrdiff_t delta) {
            element = (Element*)((uint8_t *)element - delta*entsize);
            index -= (int32_t)delta;
            return *this;
        }
        const iterator operator + (ptrdiff_t delta) const {
            return iterator(*this) += delta;
        }
        const iterator operator - (ptrdiff_t delta) const {
            return iterator(*this) -= delta;
        }

        iterator& operator ++ () { *this += 1; return *this; }
        iterator& operator -- () { *this -= 1; return *this; }
        iterator operator ++ (int) {
            iterator result(*this); *this += 1; return result;
        }
        iterator operator -- (int) {
            iterator result(*this); *this -= 1; return result;
        }

        ptrdiff_t operator - (const iterator& rhs) const {
            return (ptrdiff_t)this->index - (ptrdiff_t)rhs.index;
        }

        Element& operator * () const { return *element; }
        Element* operator -> () const { return element; }

        operator Element& () const { return *element; }

        bool operator == (const iterator& rhs) const {
            return this->element == rhs.element;
        }
        bool operator != (const iterator& rhs) const {
            return this->element != rhs.element;
        }

        bool operator < (const iterator& rhs) const {
            return this->element < rhs.element;
        }
        bool operator > (const iterator& rhs) const {
            return this->element > rhs.element;
        }
    };
};


struct method_t {
    SEL name;
    const char *types;
    IMP imp;
};

//typedef struct method_t {
//    SEL name;
//    const char *types;
//    IMP imp;
//} method_t;

//MAKE_LIST_T(method);



struct method_list_t : entsize_list_tt<method_t, method_list_t, 0x3> {
    bool isUniqued() const;
    bool isFixedUp() const;
    void setFixedUp();

    uint32_t indexOfMethod(const method_t *meth) const {
        uint32_t i =
            (uint32_t)(((uintptr_t)meth - (uintptr_t)this) / entsize());
        return i;
    }
};

struct property_t {
    const char *name;
    const char *attributes;
};

struct property_list_t : entsize_list_tt<property_t, property_list_t, 0> {
};

struct protocol_list_t {
    // count is pointer-sized by accident.
    uintptr_t count;
    protocol_ref_t list[0]; // variable-size

    size_t byteSize() const {
        return sizeof(*this) + count*sizeof(list[0]);
    }

    protocol_list_t *duplicate() const {
        return (protocol_list_t *)memdup(this, this->byteSize());
    }

    typedef protocol_ref_t* iterator;
    typedef const protocol_ref_t* const_iterator;

    const_iterator begin() const {
        return list;
    }
    iterator begin() {
        return list;
    }
    const_iterator end() const {
        return list + count;
    }
    iterator end() {
        return list + count;
    }
};

struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
    
    protocol_list_t *protocolsForMeta(bool isMeta) {
        if (isMeta) return nullptr;
        else return protocols;
    }
};

#endif
