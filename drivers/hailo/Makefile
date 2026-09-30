# SPDX-License-Identifier: GPL-2.0

obj-$(CONFIG_HAILO_PCI) += hailo_pci.o

hailo_pci-objs += pcie/src/pcie.o
hailo_pci-objs += pcie/src/fops.o
hailo_pci-objs += pcie/src/sysfs.o
hailo_pci-objs += pcie/src/nnc.o
hailo_pci-objs += pcie/src/soc.o

hailo_pci-objs += common/fw_validation.o
hailo_pci-objs += common/fw_operation.o
hailo_pci-objs += common/pcie_common.o
hailo_pci-objs += common/vdma_common.o
hailo_pci-objs += common/hailo_resource.o

hailo_pci-objs += utils/logs.o

hailo_pci-objs += vdma/vdma.o
hailo_pci-objs += vdma/memory.o
hailo_pci-objs += vdma/ioctl.o

ccflags-y += -Werror
ccflags-y += -I$(src)
ccflags-y += -I$(src)/common
ccflags-y += -I$(src)/pcie/src
ccflags-y += -I$(src)/utils
ccflags-y += -I$(src)/vdma
ccflags-y += -DHAILO_RASBERRY_PIE